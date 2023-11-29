//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation

enum SetLocationEndPoints: String {
    
    case getCities
    case registerLocation
    case updateUserLocation
    case getUserLocation
    
    struct LocationServicesPath {
        static let user = "user"
        static let location = "location"
        static let addressBook = "addressBook"
    }
    
}

extension SetLocationEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getCities:
            return "location/v1/get-cities"
        case .registerLocation:
            return LocationServicesPath.user + "/v1/register"
        case .updateUserLocation:
            return LocationServicesPath.location + "/v1/update-location"
        case .getUserLocation:
            return LocationServicesPath.addressBook + "/v1/get-user-location"
        }
    }
}
