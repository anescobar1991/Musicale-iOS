//
//  LocationChangeTableViewController.swift
//  
//
//  Created by Andres Escobar on 6/5/15.
//
//

import UIKit
import CoreLocation

class LocationChangeTableViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var locationsTableView: UITableView!
  @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
  
  private var messageLabel = UILabel()
  private var progressBar = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  private var locationManager = CLLocationManager()
  private var dataManager = PersistentDataManager.sharedInstance

  private var places: [CLPlacemark] = []
  
  private var keyboardHeight: CGFloat!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    
    searchBar.delegate = self
    
    configureUIPieces()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    searchBar.becomeFirstResponder()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        keyboardHeight = keyboardSize.height
        animateTableViewUp(true)
      }
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    self.animateTableViewUp(false)
  }
  
  
  private func animateTableViewUp(up: Bool) {
    let movement = (up ? keyboardHeight : -keyboardHeight)
    
    UIView.animateWithDuration(0.3, animations: {
      self.tableViewBottomConstraint.constant += movement
      self.view.layoutIfNeeded()
    })
  }
  
  private func determineLocationServicesAuthorization(status: CLAuthorizationStatus) {
    
      switch status {
      case .AuthorizedWhenInUse, .AuthorizedAlways:
          locationManager.startUpdatingLocation()
      case .NotDetermined:
        locationManager.requestWhenInUseAuthorization()
      case .Restricted, .Denied:
        let alertController = UIAlertController(
          title: "Location Access Disabled",
          message: "In order to get your current location you must allow us to do so. Please open Musicale's settings and set location access to 'While Using the App'.",
          preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
          if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
          }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
      }
    }

  
  @IBAction func onUseCurrentLocationTouchUp(sender: AnyObject) {
    determineLocationServicesAuthorization(CLLocationManager.authorizationStatus())
    let button = sender as! UIButton
    button.backgroundColor = UIColor.whiteColor()
  }
  
  @IBAction func onUseCurrentLocationTouchDown(sender: AnyObject) {
    let button = sender as! UIButton
    button.backgroundColor = UIColor.groupTableViewBackgroundColor()
  }
  
  @IBAction func onUseCurrentLocationTouchDragOutside(sender: AnyObject) {
    
    let button = sender as! UIButton
    button.backgroundColor = UIColor.whiteColor()
  }
  
  private func configureTableViewAesthetics() {
    locationsTableView.backgroundView = nil
    if (places.count < 2) {
      locationsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    } else {
      locationsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }
  }
  
  private func configureUIPieces() {
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = UIColor.darkGrayColor()
    messageLabel.textAlignment = NSTextAlignment.Center
    progressBar.center = locationsTableView.center
    progressBar.hidesWhenStopped = true
  }
  
  private func setTableViewMessageLabel(message: String) {
    messageLabel.text = message
    locationsTableView.backgroundView = messageLabel
  }
  
  private func displayProgressBar(display: Bool) {
    if (display) {
      locationsTableView.backgroundView = progressBar
      progressBar.startAnimating()
    } else {
      locationsTableView.backgroundView = nil
      progressBar.stopAnimating()
    }
  }
  
}

// MARK: - UISearchBarDelegate
extension LocationChangeTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    places.removeAll(keepCapacity: false)
    configureTableViewAesthetics()
    locationsTableView.reloadData()
    
    displayProgressBar(true)

    let geoCoder = CLGeocoder()
    
    let addressString = searchBar.text
    
    //TODO: only do this if network connection
    geoCoder.geocodeAddressString(addressString, completionHandler:
      {(placemarks: [AnyObject]!, error: NSError!) in
        
        self.displayProgressBar(false)

        if error != nil {
          if (error.code == 8) {
            self.setTableViewMessageLabel("No locations found for your search")
          } else {
            self.setTableViewMessageLabel("Oops! This one is on us, something has gone wrong. Try searching again.")
          }
        } else {
          if placemarks.count > 0 {
            let placeResults = placemarks as! [CLPlacemark]
            self.places.extend(placeResults)
            self.configureTableViewAesthetics()
            self.locationsTableView.reloadData()
          }
        }
    })
  }
  
}

// MARK: - UITableViewDataSource
extension LocationChangeTableViewController : UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("locationResultCell", forIndexPath: indexPath) as! UITableViewCell
    
    let place = places[indexPath.row]
    
    cell.textLabel?.text = place.name
    if let locality = place.locality {
      cell.detailTextLabel?.text = "\(locality), \(place.administrativeArea) \(place.country)"
    } else {
      cell.detailTextLabel?.text = "\(place.administrativeArea) \(place.country)"
    }

    return cell
  }
  
}

extension LocationChangeTableViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    dataManager.searchLocation = places[indexPath.row].location
    dataManager.searchPlace = places[indexPath.row]
  }
  
}

// MARK: - CLLocationManagerDelegate
extension LocationChangeTableViewController: CLLocationManagerDelegate {

  
  func locationManager(manager: CLLocationManager!,
    didUpdateLocations locations: [AnyObject]!) {
      locationManager.stopUpdatingLocation()
      
      let latestLocation = locations[locations.count - 1] as! CLLocation
      
      dataManager.searchLocation = latestLocation
      dataManager.searchPlace = nil
      performSegueWithIdentifier("unwindToMoreView", sender: nil)
  }
  
}
