import CoreLocation


class PersistentDataManager {
  var searchPlace: CLPlacemark?
  var searchLocation: CLLocation?
  var eventResultsPage: Int = 0
  var eventResultsTotalPages: Int?
  private var events: [Event] = []
      
  static let sharedInstance = PersistentDataManager()
  
  func getEvents() -> [Event] {
    return self.events
  }
  
  func addToEvents(events : [Event]) {
    self.events.extend(events)
  }
    
  func clearEvents() {
    self.events = []
  }
  
}
