//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import NetworkingLayer

// if you wish you can have multiple services like this in a project
enum SetLocationRequestBuilder {
    
    // organise all the end points here for clarity
    case getCities(request: GetCitiesRequest)
    case updateLocation(request: RegisterLocationRequest)
    case registerLocation(request: RegisterLocationRequest)
    case getUserLocation(request: RegisterLocationRequest)
    
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getCities:
            return .POST
        case .updateLocation:
            return .POST
        case .registerLocation:
            return .POST
        case .getUserLocation:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    public func createRequest(baseUrl: String, endPoint: SetLocationEndPoints) -> NetworkRequest {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(baseUrl: baseUrl, endPoint: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .getCities(let request):
            return request
        case .updateLocation(let request):
            return request
        case .registerLocation(let request):
            return request
        case .getUserLocation(let request):
            return request
        }
    }
    
    // compose urls for each request
    func getURL(baseUrl: String, endPoint: SetLocationEndPoints) -> String {
        return baseUrl + endPoint.serviceEndPoints
    }
}
