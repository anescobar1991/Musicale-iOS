import UIKit
import CoreLocation


class LocationChangeTableViewController: UIViewController {
  
  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var locationsTableView: UITableView!
  @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
  
  private let messageLabel = UILabel()
  private let progressBar = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  private let locationManager = UserLocationManager()
  private let dataManager = PersistentDataManager.sharedInstance

  private var places: [CLPlacemark] = []
  
  private var keyboardHeight: CGFloat!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
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
  
  @IBAction func onUseCurrentLocationTouchUp(sender: AnyObject) {
    let button = sender as! UIButton
    button.backgroundColor = UIColor.whiteColor()
    locationManager.getCurrentLocation(self)
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


extension LocationChangeTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    places.removeAll(keepCapacity: false)
    configureTableViewAesthetics()
    locationsTableView.reloadData()
    
    displayProgressBar(true)
    
    let addressString = searchBar.text
    
    Geocoder().forwardGeocode(addressString, delegate: self)
  }
  
}


extension LocationChangeTableViewController: UITableViewDataSource {
  
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
    
    dataManager.clearEvents()
    dataManager.eventResultsTotalPages = 0
  }
  
}


extension LocationChangeTableViewController: UserLocationManagerDelegate {
  
  func aboutToGetLocation() {}

  func didGetLocation(location: CLLocation) {
    dataManager.searchLocation = location
    dataManager.searchPlace = nil
    dataManager.clearEvents()
    dataManager.eventResultsTotalPages = 0
    performSegueWithIdentifier("unwindToMoreView", sender: nil)
  }
  
  
  func locationServicesDidFailWithErrors(error: NSError) {
    setTableViewMessageLabel(AppStrings().locationUnresolvableMessage)
  }
  
  func doesNotHaveLocationServicesAuthorization(status: CLAuthorizationStatus) {
    let alertController = UIAlertController(
      title: AppStrings().locationAccessDisabledAlertViewTitle,
      message: AppStrings().locationAccessDisabledAlertViewMessage,
      preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: AppStrings().alertViewCancel, style: .Cancel, handler: nil)
      alertController.addAction(cancelAction)
    
    let openAction = UIAlertAction(title: AppStrings().locationAccessDisabledOpenSettingsButton, style: .Default) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
    alertController.addAction(openAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
}


extension LocationChangeTableViewController: ForwardGeocoderDelegate {
  
  func aboutToForwardGeocode() {}
  
  func didGetForwardGeocodedPlacemark(placemarks: [CLPlacemark]) {
    displayProgressBar(false)

    places.extend(placemarks)
    configureTableViewAesthetics()
    locationsTableView.reloadData()
  }
  
  func forwardGeocodingDidFailWithErrors(error: NSError) {
    self.displayProgressBar(false)
    
    let errorCode = error.code
    
    if (errorCode == CLError.GeocodeFoundNoResult.rawValue || errorCode == CLError.GeocodeFoundPartialResult.rawValue) {
      setTableViewMessageLabel(AppStrings().noLocationFoundMessage)
    } else if (errorCode == CLError.Network.rawValue) {
      setTableViewMessageLabel(AppStrings().networkUnavailableMessage)
    } else {
      setTableViewMessageLabel(AppStrings().genericErrorMessage)
    }
  }
  
}
