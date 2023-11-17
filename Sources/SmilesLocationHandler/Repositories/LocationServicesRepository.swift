//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol LocationServicesServiceable {
    func reverseGeoCodeToGetCompleteAddress() -> AnyPublisher<SWGoogleAddressResponse, NetworkError>
    func locationReverseGeocodingFromOSMCoordinates() -> AnyPublisher<OSMLocationResponse, NetworkError>
}

class LocationServicesRepository: LocationServicesServiceable {
    
    private var networkRequest: Requestable
    private var endPoint: LocationServicesEndPoints

    init(networkRequest: Requestable, endPoint: LocationServicesEndPoints) {
        self.networkRequest = networkRequest
        self.endPoint = endPoint
    }

    func reverseGeoCodeToGetCompleteAddress() -> AnyPublisher<SWGoogleAddressResponse, NetworkError> {
        let endPoint = LocationServicesRequestBuilder.reverseGeoCodeToGetCompleteAddress
        let request = endPoint.createRequest(endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
    func locationReverseGeocodingFromOSMCoordinates() -> AnyPublisher<OSMLocationResponse, NetworkError> {
        let endPoint = LocationServicesRequestBuilder.locationReverseGeocodingFromOSMCoordinates
        let request = endPoint.createRequest(endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
}
