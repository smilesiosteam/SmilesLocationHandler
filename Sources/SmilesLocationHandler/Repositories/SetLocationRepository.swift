//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol SetLocationServiceable {
    func getCitiesService(request: GetCitiesRequest) -> AnyPublisher<GetCitiesResponse, NetworkError>
    func updateUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError>
    func registerUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError>
    func getUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError>
}

class SetLocationRepository: SetLocationServiceable {
    
    private var networkRequest: Requestable
    private var baseUrl: String
    private var endPoint: SetLocationEndPoints

    init(networkRequest: Requestable, baseUrl: String, endPoint: SetLocationEndPoints) {
        self.networkRequest = networkRequest
        self.baseUrl = baseUrl
        self.endPoint = endPoint
    }

    func getCitiesService(request: GetCitiesRequest) -> AnyPublisher<GetCitiesResponse, NetworkError> {
        let endPoint = SetLocationRequestBuilder.getCities(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl, endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
    func updateUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError> {
        let endPoint = SetLocationRequestBuilder.updateLocation(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl, endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
    func registerUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError> {
        let endPoint = SetLocationRequestBuilder.registerLocation(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl, endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
    func getUserLocationService(request: RegisterLocationRequest) -> AnyPublisher<RegisterLocationResponse, NetworkError> {
        let endPoint = SetLocationRequestBuilder.getUserLocation(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl, endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
}
