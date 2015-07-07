//
//  Event.swift
//  musicale
//
//  Created by Andres Escobar on 4/14/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//
import CoreLocation

class Event {
  
  var title: String
  var date: String
  var venueName: String
  var imageUrl: String
  var latLng: CLLocationCoordinate2D
  
  init(title: String, date: String, venueName: String, imageUrl: String,
    latLng: CLLocationCoordinate2D) {
      
    self.title = title
    self.date = date
    self.venueName = venueName
    self.imageUrl = imageUrl
    self.latLng = latLng
  }
  
}
