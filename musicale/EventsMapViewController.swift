import UIKit
import MapKit

class EventsMapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet private weak var mapView: MKMapView!
  
  private let clusteringManager = FBClusteringManager()
  private let dataManager = PersistentDataManager.sharedInstance
  
  private var eventLocations = Set<FBAnnotation>()
  
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
      
      //if pin's coordinates already exist on map (multiple events at same venue) then will place pin at slightly different location
      if eventLocations.contains(pin) {
        let lat = Double(pin.coordinate.latitude)
        let lng = Double(pin.coordinate.longitude)
        let newLat = lat * (Double.random() * (1.000001 - 0.9999999) + 0.9999999)
        let newLng = lng * (Double.random() * (1.000001 - 0.9999999) + 0.9999999)
        let newCoordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
        pin.coordinate = newCoordinate
      }

      //add pin's coordinates to variable that keeps track of all coordinates to be placed on map
      eventLocations.insert(pin)
      pins.append(pin)
    }
    return pins
  }
  
}