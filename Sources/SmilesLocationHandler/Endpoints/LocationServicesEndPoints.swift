//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import Foundation
import CoreLocation
import SmilesUtilities

enum LocationServicesEndPoints {
    
    case reverseGeoCodeToGetCompleteAddress(latLong: String, key: String)
    case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
    
    struct LocationServicesBaseUrl {
        static let googleMaps = "https://maps.googleapis.com/"
        static let openStreetMap = "https://nominatim.openstreetmap.org/"
    }
    
}

extension LocationServicesEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .reverseGeoCodeToGetCompleteAddress(let latLong, let key):
            return LocationServicesBaseUrl.googleMaps + "maps/api/geocode/json?latlng=\(latLong)&key=\(key)"
        case .locationReverseGeocodingFromOSMCoordinates(let coordinates, let format):
            return LocationServicesBaseUrl.openStreetMap + "reverse?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&format=\(format.rawValue)"
        }
    }
}
