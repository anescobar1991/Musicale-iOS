//
//  LastFmDataProvider.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import Alamofire

protocol LastFMDataProviderDelegate {
  func aboutToGetEvents()
  func didGetEvents()
//  func afterGetEvents() -> [Event]
}

class LastFmDataProvider {
  private var delegate: LastFMDataProviderDelegate
  private var persistentDataManager = PersistentDataManager.sharedInstance

  init(delegate :LastFMDataProviderDelegate) {
    self.delegate = delegate
  }
  
  func getEvents() -> [Event] {
    delegate.aboutToGetEvents()
    Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
      .response { (request, response, data, error) in
        self.delegate.didGetEvents()
    }
    
    return persistentDataManager.getEvents()
  }
    
  func addToEvents(events : [Event]) {
    persistentDataManager.addToEvents(events)
  }
    
  func clearEvents() {
    persistentDataManager.clearEvents()
  }
    
}
