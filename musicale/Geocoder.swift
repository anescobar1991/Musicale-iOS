import CoreLocation


protocol ReverseGeocoderDelegate {
  func aboutToReverseGeocode()
  func didGetReverseGeocodedPlacemark(placemarks: [CLPlacemark])
  func reserveGeocodingDidFailWithErrors(error: NSError)
}


protocol ForwardGeocoderDelegate {
  func aboutToForwardGeocode()
  func didGetForwardGeocodedPlacemark(placemarks: [CLPlacemark])
  func forwardGeocodingDidFailWithErrors(error: NSError)
}


class Geocoder {
  private var geocoder = CLGeocoder()
  private var reverseGeocoderDelegate: ReverseGeocoderDelegate!
  private var forwardGeocoderDelegate: ForwardGeocoderDelegate!
  
  func reverseGeocode(location: CLLocation, delegate: ReverseGeocoderDelegate) {
    self.reverseGeocoderDelegate = delegate

    geocoder.reverseGeocodeLocation(location, completionHandler:
      {(placemarks, error) -> Void in
      
      if error != nil {
        delegate.reserveGeocodingDidFailWithErrors(error)
      } else {
        if placemarks.count > 0 {
          let placeResults = placemarks as! [CLPlacemark]
          
          delegate.didGetReverseGeocodedPlacemark(placeResults)
        }
      }
    })
  }
  
  func forwardGeocode(address: String, delegate: ForwardGeocoderDelegate) {
    self.forwardGeocoderDelegate = delegate
    
    geocoder.geocodeAddressString(address, completionHandler:
      {(placemarks: [AnyObject]!, error: NSError!) in
        
        delegate.aboutToForwardGeocode()
        
        if error != nil {
          delegate.forwardGeocodingDidFailWithErrors(error)
        } else {
          if placemarks.count > 0 {
            let placeResults = placemarks as! [CLPlacemark]
            
            delegate.didGetForwardGeocodedPlacemark(placeResults)
          }
        }
    })
  }
  
}
