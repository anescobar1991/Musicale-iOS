//
//  LocationProvider.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import CoreLocation

class LocationProvider {
    private var locationManager: CLLocationManager
    private var geocoder :CLGeocoder
    private var persistenceManager :PersistenceManager
    
    init(delegate :CLLocationManagerDelegate) {
        geocoder = CLGeocoder()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        persistenceManager = PersistenceManager.sharedInstance
        
        locationManager.delegate = delegate
    }
    
    func startGettingCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func getSearchPlace() -> CLPlacemark {
        return persistenceManager.getSearchPlace()
    }
    
    func setSearchPlace(placemark :CLPlacemark) {
        persistenceManager.setSearchPlace(placemark)
    }
    
    func getSearchLocation() -> CLLocation {
        return persistenceManager.getSearchLocation()
    }
    
    func setSearchLocation(location :CLLocation) {
        persistenceManager.setSearchLocation(location)
    }
    
    func stopGettingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
