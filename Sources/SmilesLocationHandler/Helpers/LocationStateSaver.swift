//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

@objc public class LocationStateSaver: NSObject {
    
    public static func saveLocationInfo(_ userLocation: AppUserInfo?) {
        if let userLoc = userLocation {
            UserDefaults.standard.set(try! PropertyListEncoder().encode(userLoc), forKey: UserDefaultKeys.locationSaver)
            SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo = userLoc
        }
    }

    public static func getLocationInfo() -> AppUserInfo? {
        if let userLocation = UserDefaults.standard.data(forKey: UserDefaultKeys.locationSaver) {
            return try! PropertyListDecoder().decode(AppUserInfo.self, from: userLocation)
        }
        return nil
    }

    public static func removeLocation() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.locationSaver)
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo = nil
    }
    
    //MARK: - Recent Locations
    
    public static func saveRecentLocationObject (_ location: [SearchLocationResponseModel]?) {
        if let loc = location {
            UserDefaults.standard.set(try! PropertyListEncoder().encode(loc), forKey: UserDefaultKeys.recentLocationSaver)
        }
    }
    
    public static func getRecentLocations() -> [SearchLocationResponseModel]? {
        if let location = UserDefaults.standard.data(forKey: UserDefaultKeys.recentLocationSaver) {
            return try! PropertyListDecoder().decode([SearchLocationResponseModel].self, from: location)
        }
        return nil
    }
    
    public static func removeRecentLocations() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.recentLocationSaver)
    }
    
    //MARK: - Check Rating View
    
    public static func saveRatingState (_ shown: Bool?) {
        if let ratingState = shown {
            UserDefaults.standard.setValue(ratingState, forKey: UserDefaultKeys.iOSRatingState)
        }
    }
    
    public static func getRatingState() -> Bool? {
        return UserDefaults.standard.bool(forKey: UserDefaultKeys.iOSRatingState)
    }
    
    @objc public func checkIfLocationIdIsNil() -> Bool {
        if let _ = LocationStateSaver.getLocationInfo()?.locationId {
            return false
        } else {
            return true
        }
    }
    
    @objc public func checkIfLatLongIsNil() -> Bool {
        if let loc = LocationStateSaver.getLocationInfo()?.location,!loc.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    
    @objc public func checkIfMambaIdIsNil() -> Bool {
        if let _ = LocationStateSaver.getLocationInfo()?.mambaId {
            return false
        } else {
            return true
        }
    }
    
    @objc public func getLocationFromLocationSaver() -> Any? {
        if let locationInfo = LocationStateSaver.getLocationInfo() {
            return locationInfo
        } else {
            return nil
        }
    }
}
