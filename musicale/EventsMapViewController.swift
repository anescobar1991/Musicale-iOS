//
//  EventsMapViewController.swift
//  
//
//  Created by Andres Escobar on 7/12/15.
//
//

import UIKit
import MapKit

class EventsMapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet private weak var mapView: MKMapView!
  
  let clusteringManager = FBClusteringManager()
  let dataManager = PersistentDataManager.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    clusteringManager.setAnnotations([])
    
    if let location = dataManager.searchLocation {
      setMapCenterCoordinates(location)
    }
    
    var pins :[FBAnnotation] = []
    for event in dataManager.getEvents() {
      let pin = FBAnnotation()
      pin.coordinate = event.latLng
      pins.append(pin)
    }
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
  
  private func setMapCenterCoordinates(location: CLLocation) {
    let regionRadius :CLLocationDistance = 40000
    
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius, regionRadius)
    
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
}
