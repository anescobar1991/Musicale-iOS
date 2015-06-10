//
//  MoreOptionsTableViewController.swift
//  musicale
//
//  Created by Andres Escobar on 6/6/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import UIKit
import CoreLocation

class MoreOptionsTableViewController: UITableViewController {
  
  let persistentData = PersistentDataManager.sharedInstance

  @IBOutlet weak var searchLocation: UILabel!
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    loadSearchLocationLabel()
  }
  
  @IBAction func unwindToMoreView(sender: UIStoryboardSegue) {
    loadSearchLocationLabel()
  }
  
  private func loadSearchLocationLabel() {
    if let place = persistentData.searchPlace {
      searchLocation.text = sanitizePlaceToDisplay(place)
    } else {
      let location = persistentData.searchLocation
      
      CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void
        in
        
        if error != nil {
          //TODO: do something here if error...
          return
        }
        
        if placemarks.count > 0 {
          let place = placemarks[0] as! CLPlacemark
          self.persistentData.searchPlace = place
          self.searchLocation.text = self.sanitizePlaceToDisplay(place)
        }
        else {
          //TODO: do something here if error...
        }
      })
    }
  }
  
  private func sanitizePlaceToDisplay(place: CLPlacemark) -> String {
    var placeStringArray :[String] = []
    
    if let name = place.name { placeStringArray.append("\(name) -") }
    if let locality = place.locality { placeStringArray.append("\(locality),") }
    
    placeStringArray.append(place.country)
    
    let sanitizedPlaceString = " ".join(placeStringArray)
    
    return sanitizedPlaceString
  }


  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

}