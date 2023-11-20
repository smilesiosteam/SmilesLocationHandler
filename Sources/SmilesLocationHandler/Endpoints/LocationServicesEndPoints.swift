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
    case getAutoCompleteResultsFromOSM(location: String, format: OSMResponseType, limit: Int, addressDetails: Bool)
    case getLocationDetailsFromGoogle(placeId: String, key: String)
    case getLocationDetailsFromOSM(osmId: String, format: OSMResponseType)
    
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
        case .getAutoCompleteResultsFromOSM(let location, let format, let limit, let addressDetails):
            return LocationServicesBaseUrl.openStreetMap + "search?q=\(location)&format=\(format)&addressdetails=\(addressDetails ? 1 : 0)&limit=\(limit)&countrycodes=AE"
        case .getLocationDetailsFromGoogle(let placeId, let key):
            return LocationServicesBaseUrl.googleMaps + "maps/api/place/details/json?placeid=\(placeId)&key=\(key)"
        case .getLocationDetailsFromOSM(let osmId, let format):
            return LocationServicesBaseUrl.openStreetMap + "lookup?osm_ids=\(osmId)&format=\(format)"
        }
    }
}
