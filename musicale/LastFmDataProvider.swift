//
//  LastFmDataProvider.swift
//  musicale
//
//  Created by Andres Escobar on 6/3/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation

class LastFmDataProvider {
    
    let events : [Event] = [
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
        Event(title: "GQ asdfjaslkfjaslkjf lkasjlfkj ;asjf;jasfjsa;jf ", date: "July 10 2020", location: "Crescent Ballroom lasdflkasjlfkj ", imageUrl: "https://download.unsplash.com/photo-1427348693976-99e4aca06bb9")
    ]
    
    private var persistenceManager = PersistenceManager.sharedInstance
    
    func getEvents() -> [Event] {
        addToEvents(events) //TODO: remove after integrating with last FM
        
        return persistenceManager.getEvents()
    }
    
    func addToEvents(events : [Event]) {
        persistenceManager.addToEvents(events)
    }
    
    func clearEvents() {
        persistenceManager.clearEvents()
    }
    
}
