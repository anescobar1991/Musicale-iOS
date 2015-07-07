//
//  LastFmDataProvider.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

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
  
  func getEvents(latLng :CLLocationCoordinate2D, pageNumber :Int = 1, resultsLimit :Int = 25, searchRadius :Int = 100) {
    delegate.aboutToGetEvents()
    
    Alamofire.request(.GET, "http://ws.audioscrobbler.com/2.0/", parameters: ["method": "geo.getevents", "lat": latLng.latitude, "long": latLng.longitude, "api_key": apiKey, "format": "json", "page": pageNumber, "limit": resultsLimit, "distance": searchRadius])
      .responseJSON { (request, response, data, error) in
        if let error = error {
          self.delegate.didGetEventsWithError(error)
        } else {
          let json = JSON(data!)
          
          let dataManager = PersistentDataManager.sharedInstance
          dataManager.eventResultsPage = json["events"]["@attr"]["page"].string!.toInt()
          dataManager.eventResultsTotalPages = json["events"]["@attr"]["totalPages"].string!.toInt()
          
          var events :[Event] = []
          if let eventsArray = json["events"]["event"].array {
            
            for event in eventsArray {
              let title = event["title"].string
              var date = event["startDate"].string
              let range = Range(start:advance(date!.startIndex, 4), end: advance(date!.startIndex, 16))
              date = date?.substringWithRange(range)

              let venueName = event["venue"]["name"].string
              let imageUrl = event["image"].array!.last!["#text"].string
              
              let lat = (event["venue"]["location"]["geo:point"]["geo:lat"].string! as NSString).doubleValue
              let lng = (event["venue"]["location"]["geo:point"]["geo:long"].string! as NSString).doubleValue
              let latLng = CLLocationCoordinate2D(latitude: lat, longitude: lng)
              
              let event = Event(title: title!, date: date!, venueName: venueName!, imageUrl: imageUrl!, latLng: latLng)
              events.append(event)
            }
            
          } else {
            let eventMap = json["events"]["event"]
            
            let title = eventMap["title"].string
            let date = eventMap["startDate"].string
            let venueName = eventMap["venue"]["name"].string
            let imageUrl = eventMap["image"].array!.last!["#text"].string
            
            let lat = (eventMap["venue"]["location"]["geo:point"]["geo:lat"].string! as NSString).doubleValue
            let lng = (eventMap["venue"]["location"]["geo:point"]["geo:long"].string! as NSString).doubleValue
            let latLng = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let event = Event(title: title!, date: date!, venueName: venueName!, imageUrl: imageUrl!, latLng: latLng)
            events.append(event)
          }
          
          self.delegate.didGetEvents(events)
        }
    }
  }
    
}
