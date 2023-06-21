//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Alamofire
import Foundation
import SmilesBaseMainRequestManager
import SmilesUtilities
import NetworkingLayer
import CoreLocation

public enum LocationRouter: URLRequestConvertible {
    case getCitiesList
    case registerUserLocation(request: RegisterLocationRequest)
    case updateUserLocation(request: RegisterLocationRequest)
    case getLocationWithLatLong(request: RegisterLocationRequest)
    case autoComplete(request: SWMapAutoCompleteRequestModel)
    case autoCompleteDetail(request: SWAutoCompleteDetailsRequestModel)
    case reverseGeoCodeToGetCompleteAddress(requst: SWGoogleAddressRequestModel)
    case removeAddress(request: RemoveAddressRequestModel)
    case saveDefaultAddress(request: RemoveAddressRequestModel)
    case getAllAddresss(requst: RegisterLocationRequest)
    case getPolyLine(request: PolyLineRequestModel)
    case osmLocationForwardGeocoding(address: String, format: OSMResponseType, limit: Int, addressDetails: Bool)
    case locationReverseGeocodingFromOSMId(osmId: String, format: OSMResponseType)
    case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
    
    
    public var methods: Alamofire.HTTPMethod {
        switch self {
        case .getCitiesList:
            return .post
        case .registerUserLocation:
            return .post
        case .updateUserLocation:
            return .post
        case .getLocationWithLatLong:
            return .post
        case .autoComplete:
            return .get
        case .autoCompleteDetail:
            return .get
        case .reverseGeoCodeToGetCompleteAddress:
            return .get
        case .getAllAddresss:
            return .post
        case .saveDefaultAddress:
            return .post
        case .removeAddress:
            return .post
        case .getPolyLine:
            return .get
        case .osmLocationForwardGeocoding:
            return .get
        case .locationReverseGeocodingFromOSMId:
            return .get
        case .locationReverseGeocodingFromOSMCoordinates:
            return .get
            
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getCitiesList:
            let request = GuestUserLoginRequestModel()
            request.isGuestUser = AppCommonMethods.isGuestUser
            return request.asDictionary(dictionary: SmilesBaseMainRequestManager.shared.getConfigsAsDictionary())

        case .registerUserLocation(let request):
            var baseRequestDict = SmilesBaseMainRequestManager.shared.getConfigsAsDictionary()
            var userInfo = baseRequestDict["userInfo"] as? [String:Any]
            userInfo?["latitude"] = request.userInfo?.latitude
            userInfo?["longitude"] = request.userInfo?.longitude
            
            if AppCommonMethods.isGuestUser {
                userInfo?["cityName"] = ""
                userInfo?["locationId"] = ""
                userInfo?["location"] = ""
                userInfo?["cityId"] = ""
            }
            
            baseRequestDict["userInfo"] = userInfo
            return request.asDictionary(dictionary: baseRequestDict)
            
        case .updateUserLocation(let request):
            var baseRequestDict = SmilesBaseMainRequestManager.shared.getConfigsAsDictionary()
            var userInfo = baseRequestDict["userInfo"] as? [String:Any]
            userInfo?["latitude"] = request.userInfo?.latitude
            userInfo?["longitude"] = request.userInfo?.longitude
            if AppCommonMethods.isGuestUser {
                userInfo?["cityName"] = ""
                userInfo?["locationId"] = ""
                userInfo?["location"] = ""
                userInfo?["cityId"] = ""
            }
            
            baseRequestDict["userInfo"] = userInfo
            return request.asDictionary(dictionary: baseRequestDict)

        case .getLocationWithLatLong(let request):
            return request.asDictionary(dictionary: SmilesBaseMainRequestManager.shared.getConfigsAsDictionary())
            
        case .autoComplete:
            return nil
            
        case .autoCompleteDetail:
            return nil
            
        case .reverseGeoCodeToGetCompleteAddress:
            return nil
            
        case .getAllAddresss(let request):
            return request.asDictionary(dictionary: SmilesBaseMainRequestManager.shared.getConfigsAsDictionary())
            
        case .saveDefaultAddress(let request):
            return request.asDictionary(dictionary: SmilesBaseMainRequestManager.shared.getConfigsAsDictionary())
            
        case .removeAddress(let request):
            return request.asDictionary(dictionary: SmilesBaseMainRequestManager.shared.getConfigsAsDictionary())
            
        case .getPolyLine:
            return nil
        case .locationReverseGeocodingFromOSMId:
            return nil
        case .locationReverseGeocodingFromOSMCoordinates:
            return nil
        case .osmLocationForwardGeocoding:
            return nil

        }
    }
    
    public var url: URL {
        let relativePath: String?
        switch self {
        case .getCitiesList:
            relativePath = EndPoints.getCitiesEndPoint
            
        case .registerUserLocation:
            relativePath = EndPoints.registerUserLocationEndPoint
            
        case .updateUserLocation:
            relativePath = EndPoints.updateUserLocationEndpoint
            
        case .getLocationWithLatLong:
            relativePath = EndPoints.getLocationEndpoint
            
        case .getAllAddresss:
            relativePath = EndPoints.getAllAdressesEndpoint
            
        case .saveDefaultAddress:
            relativePath = EndPoints.saveDefaultAddressEndpoint
            
        case .removeAddress:
            relativePath = EndPoints.removeAddressEndpoint
            
        case .autoComplete(let request):
            
            var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json")!
            urlComponents.queryItems = [
                URLQueryItem(name: "input", value: request.intput),
                URLQueryItem(name: "key", value: request.key)
            ]
            return urlComponents.url!
            
        case .autoCompleteDetail(let request):
            var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json")!
            urlComponents.queryItems = [
                URLQueryItem(name: "placeid", value: request.placeID),
                URLQueryItem(name: "key", value: request.key)
            ]
            return urlComponents.url!
            
        case .reverseGeoCodeToGetCompleteAddress(let request):
            var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
            urlComponents.queryItems = [
                URLQueryItem(name: "latlng", value: request.latlng),
                URLQueryItem(name: "key", value: request.key)
            ]
            return urlComponents.url!
        
        case .getPolyLine(let request):
            var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/directions/json?origin")!
            let origin = String(format: "%f,%f",request.sourceLat!,request.sourceLong!)
            let destination = String(format: "%f,%f",request.destinationLat!,request.destinationLong!)
          
            urlComponents.queryItems = [
                URLQueryItem(name: "origin", value: origin),
                URLQueryItem(name: "destination", value: destination),
                URLQueryItem(name: "sensor", value: "false"),
                URLQueryItem(name: "mode", value: "driving"),
                URLQueryItem(name: "key", value: request.apiKey)
            ]
            
            if let wayPointLat = request.wayPointsLat, let wayPointLong = request.wayPointsLong {
                urlComponents.queryItems?.append(URLQueryItem(name: "waypoints", value: String(format: "%f,%f",wayPointLat, wayPointLong)))
            }
            return urlComponents.url!
            
        case .osmLocationForwardGeocoding(let address, let format, let limit, let addressDetails):
            var urlComponents = URLComponents(string: "https://nominatim.openstreetmap.org/search")!
            
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: address),
                URLQueryItem(name: "format", value: format.rawValue),
                URLQueryItem(name: "addressdetails", value: addressDetails ? "\(1)" : "\(0)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "countrycodes", value: "AE")
            ]
            
            return urlComponents.url!
            
        case .locationReverseGeocodingFromOSMId(let osmId, let format):
            var urlComponents = URLComponents(string: "https://nominatim.openstreetmap.org/lookup")!
            
            urlComponents.queryItems = [
                URLQueryItem(name: "osm_ids", value: osmId),
                URLQueryItem(name: "format", value: format.rawValue)
            ]
            
            return urlComponents.url!
            
        case .locationReverseGeocodingFromOSMCoordinates(let coordinates, let format):
            var urlComponents = URLComponents(string: "https://nominatim.openstreetmap.org/reverse")!
            
            urlComponents.queryItems = [
                URLQueryItem(name: "lat", value: "\(coordinates.latitude)"),
                URLQueryItem(name: "lon", value: "\(coordinates.longitude)"),
                URLQueryItem(name: "format", value: format.rawValue)
            ]
            
            return urlComponents.url!
        }
        
        var url = URL(string: EndPoints.baseURL ?? "")!
        if let relativePath = relativePath {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = methods.rawValue
        if EndPoints.isCustumHeaderEnabled == "true" {
            // urlRequest.addValue("etisalat_client", forHTTPHeaderField: "custom_header")
            urlRequest.addValue("pre_prod", forHTTPHeaderField: "custom_header")
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return try encoding.encode(urlRequest, with: parameters)
    }
}
