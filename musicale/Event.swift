//
//  Event.swift
//  musicale
//
//  Created by Andres Escobar on 4/14/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

class Event {
  
  var title: String
  var date: String
  var location: String
  var imageUrl: String
  
  init(title: String, date: String, location: String, imageUrl: String) {
    self.title = title
    self.date = date
    self.location = location
    self.imageUrl = imageUrl
  }
  
}
