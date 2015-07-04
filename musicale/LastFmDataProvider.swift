//
//  LastFmDataProvider.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

protocol LastFMDataProviderDelegate {
  func aboutToGetEvents()
  func didGetEvents(foundEvents :[Event])
  func didGetEventsWithError(error :NSError)
}

class LastFmDataProvider {
  private var delegate: LastFMDataProviderDelegate
  
  private let apiKey = "824f19ce3c166a10c7b9858e3dfc3235"

  init(delegate :LastFMDataProviderDelegate) {
    self.delegate = delegate
  }
  
  func getEvents(latLng :CLLocationCoordinate2D, pageNumber :Int = 1, resultsLimit :Int = 2, searchRadius :Int = 100) {
    delegate.aboutToGetEvents()
    
    Alamofire.request(.GET, "http://ws.audioscrobbler.com/2.0/", parameters: ["method": "geo.getevents", "lat": latLng.latitude, "long": latLng.longitude, "api_key": apiKey, "format": "json", "page": pageNumber, "limit": resultsLimit, "distance": searchRadius])
      .responseJSON { (request, response, data, error) in
        if let error = error {
          self.delegate.didGetEventsWithError(error)
        } else {
          let json = JSON(data!)
          //TODO: create objects out of json here
//          println(json["events"])
          
          
          self.delegate.didGetEvents([])
        }
    }
  }
    
}
