//
//  AppStrings.swift
//  musicale
//
//  Created by Andres Escobar on 7/18/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import Foundation

struct AppStrings {
  
  let noShowsInAreaMessage = "Bummer! There are no shows in this area. Try searching elsewhere."
  let locationUnresolvableMessage = "Can't figure out your current location. Do you have airplane mode on?"
  let networkUnavailableMessage = "No internet connection found. Are you connected to a network?"
  let genericErrorMessage = "Oops! This one is on us, something has gone wrong. Try searching again."
  let locationServicesDisabledMessage = "Can't get shows around you without knowing where you are. You can still set a location on the 'Change location' screen though!"
  let noLocationFoundMessage = "No locations found for your search."
  
  //UIAlertViews
  let alertViewCancel = "Cancel"
  
  let locationAccessDisabledAlertViewTitle = "Location Access Disabled"
  let locationAccessDisabledAlertViewMessage = "To find shows near you we need to know where you are! Open Musicale's settings and set location access to 'While Using the App.'"
  let locationAccessDisabledOpenSettingsButton = "Open Settings"
}
