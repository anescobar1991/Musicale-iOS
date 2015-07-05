//
//  LocationManager.swift
//  musicale
//
//  Created by Andres Escobar on 7/4/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserLocationManagerDelegate {
  func didGetLocation(location :CLLocation)
  func doesNotHaveLocationServicesAuthorization(status: CLAuthorizationStatus)
  func locationServicesDidFailWithErrors(error : NSError)
}

class UserLocationManager : NSObject, CLLocationManagerDelegate {
  private var locationManager :CLLocationManager = CLLocationManager()
  private var delegate :UserLocationManagerDelegate!
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.distanceFilter = 200 //distance in meters
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
  }
  
  func getCurrentLocation(delegate :UserLocationManagerDelegate) {
    self.delegate = delegate
    
    startUpdatingLocationIfAuthorized(CLLocationManager.authorizationStatus())
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    delegate.locationServicesDidFailWithErrors(error)
  }
  
  func locationManager(manager: CLLocationManager!,
    didUpdateLocations locations: [AnyObject]!) {
      
      locationManager.stopUpdatingLocation()
      let latestLocation = locations[locations.count - 1] as! CLLocation
      delegate.didGetLocation(latestLocation)
  }
  
  private func startUpdatingLocationIfAuthorized(status: CLAuthorizationStatus) {
    switch status {
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      locationManager.startUpdatingLocation()
    case .NotDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .Restricted, .Denied:
      delegate.doesNotHaveLocationServicesAuthorization(status)
    }
  }
  
}
