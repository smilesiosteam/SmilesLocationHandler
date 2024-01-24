//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 21/11/2023.
//

import Foundation

struct Constants {
    
    struct Keys {
        static let recentLocation = "recentLocation"
        static let googleAppKey = "GoogleAppKey"
        static let shouldUpdateMamba = "shouldUpdateMamba"
    }
    
    struct AnalyticsEvent {
        static let locationRegistrationFailed = "location_registered_fail"
        static let locationEnabled = "location_enabled"
        static let locationDisabled = "location_disabled"
        static let locationRegistered = "location_registered_success"
        static let locationUpdated = "location_updated_success"
    }
    static var switchToOpenStreetMap: Bool = true
    
}
