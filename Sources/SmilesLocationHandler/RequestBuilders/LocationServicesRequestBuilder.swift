//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import Foundation
import NetworkingLayer

// if you wish you can have multiple services like this in a project
enum LocationServicesRequestBuilder {
    
    // organise all the end points here for clarity
    case reverseGeoCodeToGetCompleteAddress
    case locationReverseGeocodingFromOSMCoordinates
    case getAutoCompleteResultsFromOSM
    case getLocationDetailsFromGoogle
    case getLocationDetailsFromOSM
    
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .reverseGeoCodeToGetCompleteAddress:
            return .GET
        case .locationReverseGeocodingFromOSMCoordinates:
            return .GET
        case .getAutoCompleteResultsFromOSM:
            return .GET
        case .getLocationDetailsFromGoogle:
            return .GET
        case .getLocationDetailsFromOSM:
            return .GET
        }
    }
    
    // compose the NetworkRequest
    public func createRequest(endPoint: LocationServicesEndPoints, isAcceptLanguageEnabled: Bool = false) -> NetworkRequest {
        
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        if isAcceptLanguageEnabled {
            headers["Accept-Language"] = "en-US"
        }
        return NetworkRequest(url: getURL(endPoint: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
        
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .reverseGeoCodeToGetCompleteAddress:
            return nil
        case .locationReverseGeocodingFromOSMCoordinates:
            return nil
        case .getAutoCompleteResultsFromOSM:
            return nil
        case .getLocationDetailsFromGoogle:
            return nil
        case .getLocationDetailsFromOSM:
            return nil
        }
    }
    
    // compose urls for each request
    func getURL(endPoint: LocationServicesEndPoints) -> String {
        return endPoint.serviceEndPoints
    }
}
