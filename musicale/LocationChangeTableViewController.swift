//
//  LocationChangeTableViewController.swift
//  
//
//  Created by Andres Escobar on 6/5/15.
//
//

import UIKit
import CoreLocation

class LocationChangeTableViewController: UITableViewController {
  
  @IBOutlet var locationsTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  private var places: [CLPlacemark] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
  }

}

// MARK: - UISearchBarDelegate
extension LocationChangeTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    self.places.removeAll(keepCapacity: false)
    self.locationsTableView.reloadData()

    let geoCoder = CLGeocoder()
    
    let addressString = searchBar.text
    
    //TODO: only do this if network connection
    geoCoder.geocodeAddressString(addressString, completionHandler:
      {(placemarks: [AnyObject]!, error: NSError!) in
        
        if error != nil {
          //TODO: do something here if error...
        } else {
          if placemarks.count > 0 {
            let placeResults = placemarks as! [CLPlacemark]
            placeResults[0].location
            self.places.extend(placeResults)
            self.locationsTableView.reloadData()
          } else {
            //TODO: what to do if no results come back...
          }
        }
    })
  }
  
}

// MARK: - UITableViewDataSource
extension LocationChangeTableViewController : UITableViewDataSource {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("locationResultCell", forIndexPath: indexPath) as! UITableViewCell
    
    cell.textLabel?.text = sanitizePlaceToDisplay(places[indexPath.row])

    return cell
  }
  
  private func sanitizePlaceToDisplay(place: CLPlacemark) -> String {
    var placeStringArray :[String] = []
    
    if let name = place.name { placeStringArray.append("\(name) -") }
    if let locality = place.locality { placeStringArray.append("\(locality),") }
    
    placeStringArray.append(place.country)
    
    let sanitizedPlaceString = " ".join(placeStringArray)

    return sanitizedPlaceString
  }
  
}

extension LocationChangeTableViewController: UITableViewDelegate {
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let dataManager = PersistentDataManager.sharedInstance
    
    dataManager.searchLocation = places[indexPath.row].location
    dataManager.searchPlace = places[indexPath.row]
  }
  
}
