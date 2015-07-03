//
//  EventsViewController.swift
//  musicale
//
//  Created by Andres Escobar on 4/18/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class EventsViewController: UIViewController {
  
  private let regionRadius: CLLocationDistance = 40000
  private var events: [Event] = []
  private var messageLabel = UILabel()
  private var refreshControl = UIRefreshControl()
  private var locationManager = CLLocationManager()
  private var lastFmDataProvider :LastFmDataProvider!
  private var dataManager = PersistentDataManager.sharedInstance
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var eventsTableView: UITableView!
  
  override func viewDidLoad() {
      
    super.viewDidLoad()
    
    lastFmDataProvider = LastFmDataProvider(delegate: self)
    locationManager.delegate = self
    locationManager.distanceFilter = 10000
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    configureTableView()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    determineLocationServicesAuthorization(CLLocationManager.authorizationStatus())
  }
  
  func refreshData(sender:AnyObject) {
    loadTableWithEvents()
    
    refreshControl.endRefreshing()
  }
  
  private func configureTableView() {
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = UIColor.darkGrayColor()
    messageLabel.textAlignment = NSTextAlignment.Center
    
    refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
    eventsTableView.addSubview(refreshControl)
    
    eventsTableView.rowHeight = UITableViewAutomaticDimension
    eventsTableView.estimatedRowHeight = 100.0
  }
  
  private func loadTableWithEvents() {
    events = lastFmDataProvider.getEvents()
        
    if (events.isEmpty) {
        messageLabel.text = "There are no events in this area. Maybe search elsewhere?"
        eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        eventsTableView.backgroundView = messageLabel;
    } else {
        eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        eventsTableView.backgroundView = nil
    }
    
    eventsTableView.reloadData()
  }
  
  private func loadMapWithEvents() {
    //TODO add pins here using library https://github.com/ribl/FBAnnotationClusteringSwift
  }
  
  private func setMapCenterCoordinates(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        regionRadius, regionRadius)
    
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  private func determineLocationServicesAuthorization(status: CLAuthorizationStatus) {
    
      if let searchLocation = dataManager.searchLocation {
        setMapCenterCoordinates(searchLocation)
        loadTableWithEvents()
        loadMapWithEvents()
      } else {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
          if let searchLocation = dataManager.searchLocation {
            setMapCenterCoordinates(searchLocation)
            loadTableWithEvents()
          } else {
            locationManager.startUpdatingLocation()
          }
        case .NotDetermined:
          locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
          let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to get events near you we need to know where you are! Please open this Musicale's settings and set location access to 'While Using the App'.",
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
  }

}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as!EventTableViewCell
    
    let entry = events[indexPath.row]
    
    cell.titleLabel.text = entry.title
    cell.whenWhereLabel.text = "\(entry.date) @ \(entry.location)"
    //TODO: download image here using https://github.com/onevcat/Kingfisher
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
      // Remove separator inset
      if cell.respondsToSelector("setSeparatorInset:") {
        cell.separatorInset = UIEdgeInsetsZero
      }
      
      // Prevent the cell from inheriting the Table View's margin settings
      if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
        cell.preservesSuperviewLayoutMargins = false
      }
      
      // Explictly set your cell's layout margins
      if cell.respondsToSelector("setLayoutMargins:") {
        cell.layoutMargins = UIEdgeInsetsZero
      }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
}

// MARK: - CLLocationManagerDelegate
extension EventsViewController: CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager!,
    didChangeAuthorizationStatus status: CLAuthorizationStatus) {
      
      determineLocationServicesAuthorization(status)
  }
  
  func locationManager(manager: CLLocationManager!,
    didUpdateLocations locations: [AnyObject]!) {
      locationManager.stopUpdatingLocation()
      let latestLocation = locations[locations.count - 1] as! CLLocation
      
      dataManager.searchLocation = latestLocation
      setMapCenterCoordinates(latestLocation)
      loadTableWithEvents()
  }
  
}

// MARK: - LastFMDataProviderDelegate
extension EventsViewController: LastFMDataProviderDelegate {
  
  func aboutToGetEvents() {
    //TODO: start spinner here
    println("about to start getting events")
  }
  
  func didGetEvents() {
    //TODO: stop spinner here
    println("finished getting events")

  }
  
}
