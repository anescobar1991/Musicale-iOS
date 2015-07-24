import UIKit
import CoreLocation
import MapKit
import Kingfisher


class EventsViewController: UIViewController {
  
  private let progressBar = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  private let messageLabel = UILabel()
  private let refreshControl = UIRefreshControl()
  
  private let locationManager = UserLocationManager()
  private var lastFmDataProvider :LastFmDataProvider!
  private let dataManager = PersistentDataManager.sharedInstance
  private let clusteringManager = FBClusteringManager()
  
  @IBOutlet private weak var mapView: MKMapView!
  @IBOutlet private weak var eventsTableView: UITableView!
  
  override func viewDidLoad() {
      
    super.viewDidLoad()
    
    lastFmDataProvider = LastFmDataProvider(delegate: self)
    configureTableView()
    mapView.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let searchLocation = dataManager.searchLocation {
      setMapCenterCoordinates(searchLocation)
      
      if (dataManager.getEvents().isEmpty) {
        eventsTableView.reloadData()
        lastFmDataProvider.getEvents(searchLocation.coordinate)
      } else {
        loadEventsToView()
      }
    } else {
      locationManager.getCurrentLocation(self)
    }
  }
  
  func refreshData(sender: AnyObject) {
    dataManager.eventResultsPage = 0
    dataManager.clearEvents()
    eventsTableView.reloadData()

    if let location = dataManager.searchLocation {
      lastFmDataProvider.getEvents(location.coordinate)
    } else {
      locationManager.getCurrentLocation(self)
    }
  }
  
  private func configureTableView() {
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = UIColor.darkGrayColor()
    messageLabel.textAlignment = NSTextAlignment.Center
    
    refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
    eventsTableView.addSubview(refreshControl)
    
    eventsTableView.rowHeight = UITableViewAutomaticDimension
    eventsTableView.estimatedRowHeight = 100.0
    
    progressBar.center = eventsTableView.center
    progressBar.hidesWhenStopped = true
  }
  
  private func setTableViewMessageLabel(message: String) {
    eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    messageLabel.text = message
    eventsTableView.backgroundView = messageLabel
    eventsTableView.reloadData()
  }
  
  private func displayProgressBar(display: Bool) {
    if (display) {
      eventsTableView.backgroundView = progressBar
      progressBar.startAnimating()
    } else {
      eventsTableView.backgroundView = nil
      progressBar.stopAnimating()
    }
  }
  
  private func loadEventsToView() {
    mapView.removeAnnotations(mapView.annotations)
    clusteringManager.setAnnotations([])
    
    let pins = getAnnotationsFromEventList(dataManager.getEvents())
    clusteringManager.addAnnotations(pins)
    displayClustersAndPinsOnMap()
    eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    eventsTableView.backgroundView = nil
    eventsTableView.reloadData()
  }
  
  private func setMapCenterCoordinates(location: CLLocation) {
    let regionRadius :CLLocationDistance = 30000
    
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        regionRadius, regionRadius)
    
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  private func getAnnotationsFromEventList(events: [Event]) -> [FBAnnotation] {
    var pins :[FBAnnotation] = []
    
    for event in events {
      let pin = FBAnnotation()
      pin.coordinate = event.latLng
      pins.append(pin)
    }
    return pins
  }

}


extension EventsViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as!EventTableViewCell
    
    let entry = dataManager.getEvents()[indexPath.row]
    
    cell.titleLabel.text = entry.title
    cell.whenWhereLabel.text = "\(entry.date) @ \(entry.venueName)"
    if let imageUrl = entry.imageUrl {
      cell.eventImage.kf_setImageWithURL(NSURL(string: imageUrl)!, placeholderImage: UIImage(named: "placeholder"))
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
      
      if(indexPath.row == dataManager.getEvents().count/2) {
        if ((dataManager.eventResultsPage + 1) <= dataManager.eventResultsTotalPages) {
          lastFmDataProvider.getEvents(dataManager.searchLocation!.coordinate, pageNumber: ++dataManager.eventResultsPage)
        }
      }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataManager.getEvents().count
  }
  
}


extension EventsViewController: UserLocationManagerDelegate {
  
  func aboutToGetLocation() {}
  
  func didGetLocation(location :CLLocation) {
    dataManager.eventResultsPage = 0
    dataManager.eventResultsTotalPages = 0
    dataManager.clearEvents()
    lastFmDataProvider.getEvents(location.coordinate)
    dataManager.searchLocation = location
    setMapCenterCoordinates(location)
  }
  
  func locationServicesDidFailWithErrors(error: NSError) {
    setTableViewMessageLabel(AppStrings().locationUnresolvableMessage)
  }
  
  func doesNotHaveLocationServicesAuthorization(status: CLAuthorizationStatus) {
    let alertController = UIAlertController(
      title: AppStrings().locationAccessDisabledAlertViewTitle,
      message: AppStrings().locationAccessDisabledAlertViewMessage,
      preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: AppStrings().alertViewCancel, style: .Cancel) { (action) in
      self.setTableViewMessageLabel(AppStrings().locationServicesDisabledMessage)
    }
    alertController.addAction(cancelAction)
    
    let openAction = UIAlertAction(title: AppStrings().locationAccessDisabledOpenSettingsButton, style: .Default) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
    alertController.addAction(openAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
}


extension EventsViewController: LastFMDataProviderDelegate {
  
  func aboutToGetEvents() {
    if (!refreshControl.refreshing) {
      displayProgressBar(true)
    }
  }
  
  func didGetEvents(foundEvents: [Event]) {
    dataManager.addToEvents(foundEvents)
    displayProgressBar(false)
    
    loadEventsToView()
    if (refreshControl.refreshing) {
      refreshControl.endRefreshing()
    }
  }
  
  func didGetEventsWithError(error: NSError) {
    displayProgressBar(false)

    if (error.code == -1009 && dataManager.eventResultsPage > 1) {
      setTableViewMessageLabel(AppStrings().networkUnavailableMessage)
    } else if (error.code == 8) {
      setTableViewMessageLabel(AppStrings().noShowsInAreaMessage)
    } else {
      setTableViewMessageLabel(AppStrings().genericErrorMessage)
    }
  }
  
}


extension EventsViewController: MKMapViewDelegate {
  
  func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
    displayClustersAndPinsOnMap()
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    var reuseId = ""
    if annotation.isKindOfClass(FBAnnotationCluster) {
      reuseId = "Cluster"
      var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
      clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
      return clusterView
    } else {
      reuseId = "Pin"
      var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)

      return pinView
    }
  }
  
  private func displayClustersAndPinsOnMap() {
    NSOperationQueue().addOperationWithBlock({
      let mapBoundsWidth = Double(self.mapView.bounds.size.width)
      let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
      let scale:Double = mapBoundsWidth / mapRectWidth
      let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
      self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
    })
  }
  
}
