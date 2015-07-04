//
//  PersistentenceManager.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import CoreLocation

class PersistentDataManager {
  var searchPlace :CLPlacemark?
  var searchLocation :CLLocation?
  private var events : [Event] = []
      
  static let sharedInstance = PersistentDataManager()
  
  func getEvents() -> [Event] {
    return self.events
  }
  
  func addToEvents(events : [Event]) {
    self.events.extend(events)
  }
    
  func clearEvents() {
    self.events = []
  }
  
}
