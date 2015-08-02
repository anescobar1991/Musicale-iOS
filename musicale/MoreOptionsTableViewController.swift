import UIKit
import CoreLocation


class MoreOptionsTableViewController: UITableViewController {
  
  private let persistentData = PersistentDataManager.sharedInstance

  @IBOutlet private weak var searchLocation: UILabel!
  
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
      if let location = persistentData.searchLocation {
        Geocoder().reverseGeocode(location, delegate: self)
      }
      
    }
  }
  
  private func sanitizePlaceToDisplay(place: CLPlacemark) -> String {
    var placeStringArray: [String] = []
    
    if let name = place.name { placeStringArray.append("\(name) -") }
    if let locality = place.locality { placeStringArray.append("\(locality),") }
    if let adminArea = place.administrativeArea { placeStringArray.append(adminArea) }
    if let country = place.country { placeStringArray.append(country) }
    
    let sanitizedPlaceString = " ".join(placeStringArray)
    
    return sanitizedPlaceString
  }


  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
}

extension MoreOptionsTableViewController: ReverseGeocoderDelegate {
  
  func aboutToReverseGeocode() {}
  
  func didGetReverseGeocodedPlacemark(placemarks :[CLPlacemark]) {
    let place = placemarks[0]
    persistentData.searchPlace = place
    searchLocation.text = sanitizePlaceToDisplay(place)
  }
  
  func reserveGeocodingDidFailWithErrors(error: NSError) {
    searchLocation.text = ""
  }
  
}
