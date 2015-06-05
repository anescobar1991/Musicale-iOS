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

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    CLLocationManagerDelegate {

    private let regionRadius: CLLocationDistance = 40000
    private var events : [Event] = []
    private var messageLabel = UILabel()
    private var refreshControl = UIRefreshControl()
    
    private var locationProvider :LocationProvider!
    private var lastFmDataProvider :LastFmDataProvider!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventsTableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        lastFmDataProvider = LastFmDataProvider()
        locationProvider = LocationProvider(delegate: self)
        locationProvider.startGettingCurrentLocation()
        
        configureTableView()
    }
    
    func refreshData(sender:AnyObject) {
        loadEventsTable()
        
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as!EventTableViewCell

        let entry = events[indexPath.row]
        
        cell.titleLabel.text = entry.title
        cell.whenWhereLabel.text = "\(entry.date) @ \(entry.location)"
        
        return cell
    }
    
    private func configureTableView() {
        messageLabel.numberOfLines = 0;
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.textAlignment = NSTextAlignment.Center
        
        refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        eventsTableView.addSubview(refreshControl)
        
        automaticallyAdjustsScrollViewInsets = false;

        eventsTableView.rowHeight = UITableViewAutomaticDimension
        eventsTableView.estimatedRowHeight = 100.0
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
    
    private func loadEventsTable() {
        events = lastFmDataProvider.getEvents()
        
        if (events.isEmpty) {
            messageLabel.text = "There are no events in this area. Maybe search elsewhere?"
            eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            eventsTableView.backgroundView = messageLabel;
        } else {
            eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            eventsTableView.backgroundView = nil
            eventsTableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [AnyObject]!) {
            
        var latestLocation = locations[locations.count - 1] as! CLLocation
            
        centerMapOnLocation(latestLocation)
        loadEventsTable()
        locationProvider.stopGettingLocation()
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
