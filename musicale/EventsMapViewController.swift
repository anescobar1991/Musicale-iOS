import UIKit
import MapKit

class EventsMapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet private weak var mapView: MKMapView!
  
  private let clusteringManager = FBClusteringManager()
  private let dataManager = PersistentDataManager.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
        
    if let location = dataManager.searchLocation {
      setMapCenterCoordinates(location)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    clusteringManager.setAnnotations([])
    
    let pins = getAnnotationsFromEventList(dataManager.getEvents())
    clusteringManager.addAnnotations(pins)
    
    displayClustersAndPinsOnMap()
  }
  
  func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
    displayClustersAndPinsOnMap()
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    var reuseId = ""
    
    if annotation.isKindOfClass(FBAnnotationCluster) {
      reuseId = "Cluster"
      var a = annotation as! FBAnnotationCluster
      var venueNamesArray = Set<String>()
      let events: [FBAnnotation] = a.annotations
      
      //create title for cluster based on venue names in cluster
      for event in events {
        let eventData = event.metaData as! Event
        if !venueNamesArray.contains(eventData.venueName) {
          venueNamesArray.insert(eventData.venueName)
        }
      }
      //if cluster only contains one venue then set venue name as annotation title
      if venueNamesArray.count == 1 {
        let title = " ".join(venueNamesArray)
        a.title = title
      }

      var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
      clusterView = FBAnnotationClusterView(annotation: a, reuseIdentifier: reuseId)
      
      //will only display callout if there is only one venue within cluster
      if venueNamesArray.count == 1 {
        clusterView?.canShowCallout = true
        clusterView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
      }

      return clusterView
    } else {
      reuseId = "Pin"
      var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView?.canShowCallout = true
      pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
      
      return pinView
    }
  }
  
  private func displayClustersAndPinsOnMap() {
    NSOperationQueue().addOperationWithBlock({
      let mapBoundsWidth = Double(self.mapView.bounds.size.width)
      let mapRectWidth: Double = self.mapView.visibleMapRect.size.width
      let scale:Double = mapBoundsWidth / mapRectWidth
      let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale: scale)
      self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
    })
  }
  
  private func setMapCenterCoordinates(location: CLLocation) {
    let regionRadius :CLLocationDistance = 40000
    
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius, regionRadius)
    
    mapView.setRegion(coordinateRegion, animated: false)
  }
  
  private func getAnnotationsFromEventList(events: [Event]) -> [FBAnnotation] {
    var pins :[FBAnnotation] = []
    
    for event in events {
      let pin = FBAnnotation()
      pin.coordinate = event.latLng
      pin.metaData = event
      pin.title = event.title
      pin.subtitle = event.date
      pins.append(pin)
    }
    return pins
  }
  
}