//
//  PersistentenceManager.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import CoreLocation

class PersistenceManager {
    private var searchPlace :CLPlacemark!
    private var searchLocation :CLLocation!
    private var events : [Event]! = []
    
    static let sharedInstance = PersistenceManager()
    
    func getSearchPlace() -> CLPlacemark {
        return self.searchPlace
    }
    
    func setSearchPlace(placemark :CLPlacemark) {
        self.searchPlace = placemark
    }
    
    func getSearchLocation() -> CLLocation {
        return self.searchLocation
    }
    
    func setSearchLocation(location :CLLocation) {
        self.searchLocation = location
    }
    
    func getEvents() -> [Event]{
        return self.events
    }
    
    func addToEvents(events : [Event]) {
        self.events.extend(events)
    }
    
    func clearEvents() {
        self.events = []
    }
}
