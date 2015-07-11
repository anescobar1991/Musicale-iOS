//
//  EventsViewController.swift
//  musicale
//
//  Created by Andres Escobar on 4/18/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Kingfisher

class EventsViewController : UIViewController {
  
  private var progressBar = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  private var messageLabel = UILabel()
  private var refreshControl = UIRefreshControl()
  
  private var locationManager = UserLocationManager()
  private var lastFmDataProvider :LastFmDataProvider!
  private var dataManager = PersistentDataManager.sharedInstance
  private var clusteringManager = FBClusteringManager()
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var eventsTableView: UITableView!
  
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
  
  func refreshData(sender:AnyObject) {
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
    
    if (dataManager.getEvents().isEmpty) {
      setTableViewMessageLabel("Bummer! There are no shows in this area. Try searching elsewhere.")
    } else {
      var pins :[FBAnnotation] = []
      for event in dataManager.getEvents() {
        let pin = FBAnnotation()
        pin.coordinate = event.latLng
        pins.append(pin)
      }
      clusteringManager.addAnnotations(pins)
      displayClustersAndPinsOnMap()
      eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
      eventsTableView.backgroundView = nil
    }
    eventsTableView.reloadData()
  }
  
  private func setMapCenterCoordinates(location: CLLocation) {
    let regionRadius :CLLocationDistance = 30000
    
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        regionRadius, regionRadius)
    
    mapView.setRegion(coordinateRegion, animated: true)
  }

}

// MARK: - UITableViewDataSource
extension EventsViewController : UITableViewDataSource {
  
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

// MARK: - UserLocationManagerDelegate
extension EventsViewController : UserLocationManagerDelegate {
  
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
    setTableViewMessageLabel("Can't figure out your current location. Do you have airplane mode on?")
  }
  
  func doesNotHaveLocationServicesAuthorization(status: CLAuthorizationStatus) {
    let alertController = UIAlertController(
      title: "Location Access Disabled",
      message: "To find shows near you we need to know where you are! Open Musicale's settings and set location access to 'While Using the App.'",
      preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
      self.setTableViewMessageLabel("Can't get shows around you without knowing where you are. You can still set a location on the 'Change location' screen though!")
    }
    alertController.addAction(cancelAction)
    
    let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
    alertController.addAction(openAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
}

// MARK: - LastFMDataProviderDelegate
extension EventsViewController : LastFMDataProviderDelegate {
  
  func aboutToGetEvents() {
    if (!refreshControl.refreshing) {
      displayProgressBar(true)
    }
  }
  
  func didGetEvents(foundEvents :[Event]) {
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
      setTableViewMessageLabel("No internet connection found. Are you connected to a network?")
    } else if (error.code == 8) {
      setTableViewMessageLabel("No events found in your area. Try searching elsewhere.")
    } else {
      setTableViewMessageLabel("Oops! This one is on us, something has gone wrong. Try searching again.")
    }
  }
  
}

// MARK: - MKMapViewDelegate
extension EventsViewController : MKMapViewDelegate {
  
  func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
    displayClustersAndPinsOnMap()
  }
  
  func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
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
      pinView!.pinColor = .Green
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
