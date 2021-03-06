import Alamofire
import CoreLocation
import SwiftyJSON


protocol LastFMDataProviderDelegate {
  func aboutToGetEvents()
  func didGetEvents(foundEvents: [Event])
  func didGetEventsWithError(error: NSError)
}


class LastFmDataProvider {
  private let delegate: LastFMDataProviderDelegate
  private let apiKey = "824f19ce3c166a10c7b9858e3dfc3235"
  private let lasFmHostName = "http://ws.audioscrobbler.com/2.0/"
  
  init(delegate: LastFMDataProviderDelegate) {
    self.delegate = delegate
  }
  
  func getEvents(latLng: CLLocationCoordinate2D, pageNumber: Int = 1, resultsLimit: Int = 25, searchRadius: Int = 100) {
    delegate.aboutToGetEvents()
    
    Alamofire.request(.GET, lasFmHostName, parameters: ["method": "geo.getevents", "lat": latLng.latitude, "long": latLng.longitude, "api_key": apiKey, "format": "json", "page": pageNumber, "limit": resultsLimit, "distance": searchRadius])
      .responseJSON { (request, response, data, error) in
        if let error = error {
          self.delegate.didGetEventsWithError(error)
        } else {
          let json = JSON(data!)
          
          let dataManager = PersistentDataManager.sharedInstance
          if ((json["error"].type) != .Null) {
            let error = NSError(domain: "noEventsFoundForGivenLocation", code: 8, userInfo: nil)
            self.delegate.didGetEventsWithError(error)
            return
          }
          
          dataManager.eventResultsPage = json["events"]["@attr"]["page"].string!.toInt()!
          dataManager.eventResultsTotalPages = json["events"]["@attr"]["totalPages"].string!.toInt()
          
          var events :[Event] = []
          if let eventsArray = json["events"]["event"].array {
            
            for event in eventsArray {
              events.append(self.createEventModelFromJSON(event))
            }
            
          } else {
            let event = json["events"]["event"]
            events.append(self.createEventModelFromJSON(event))
          }
          
          self.delegate.didGetEvents(events)
        }
    }
  }
  
  private func createEventModelFromJSON(json: SwiftyJSON.JSON) -> Event {
    let title = json["title"].string
    var date = json["startDate"].string
    //range for creating substring with the part of the start date we want
    let range = Range(start:advance(date!.startIndex, 4), end: advance(date!.startIndex, 16))
    date = date?.substringWithRange(range)
    
    let venueName = json["venue"]["name"].string
    let imageUrl = json["image"].array!.last!["#text"].string
    
    let lat = (json["venue"]["location"]["geo:point"]["geo:lat"].string! as NSString).doubleValue
    let lng = (json["venue"]["location"]["geo:point"]["geo:long"].string! as NSString).doubleValue
    let latLng = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    
    let event = Event(title: title!, date: date!, venueName: venueName!, imageUrl: imageUrl!, latLng: latLng)
    
    return event
  }
  
}
