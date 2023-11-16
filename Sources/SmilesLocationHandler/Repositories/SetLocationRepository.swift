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
    
}
