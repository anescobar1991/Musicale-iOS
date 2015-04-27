//
//  EventsViewController.swift
//  musicale
//
//  Created by Andres Escobar on 4/18/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var events = [Event]()
    var messageLabel = UILabel()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureTableView()
        loadEventsTable()
    }
    
    func refreshData(sender:AnyObject) {
        events = [
            Event(title: "Blink-182", date: "July 4 2015", location: "Crescent Ballroom", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "Another band", date: "July 5 2015", location: "Crescent Ballroom", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "Very long band name that will take lots of space", date: "July 8 2015", location: "Crescent Ballroom", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9"),
            Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2015", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9")
        ]
        
        loadEventsTable()
        
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func configureTableView() {
        messageLabel.numberOfLines = 0;
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.textAlignment = NSTextAlignment.Center
        
        refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        automaticallyAdjustsScrollViewInsets = false;

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
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
    
    func loadEventsTable() {
        if (events.isEmpty) {
            messageLabel.text = "There are no events in this area. Maybe search elsewhere?"
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            tableView.backgroundView = messageLabel;
        } else {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            tableView.backgroundView = nil
            tableView.reloadData()
        }
    }
    
    
    @IBAction func cancelToEventsScreen(segue:UIStoryboardSegue) {
    }

}
