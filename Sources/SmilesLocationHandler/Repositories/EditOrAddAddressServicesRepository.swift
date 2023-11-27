//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol EditOrAddAddressServicesServiceable {
    func fetchLocatuionsNickNames(request: SaveAddressRequestModel) -> AnyPublisher<SaveAddressResponseModel, NetworkError>
    func saveAddress(request: SaveAddressRequestModel) -> AnyPublisher<SaveAddressResponseModel, NetworkError>
    func getAllAddresses(request: RegisterLocationRequest) -> AnyPublisher<GetAllAddressesResponse, NetworkError>
    func removeAddresse(request: RemoveAddressRequestModel) -> AnyPublisher<RemoveAddressResponseModel, NetworkError>
    func saveDefaultAddresse(request: RemoveAddressRequestModel) -> AnyPublisher<RemoveAddressResponseModel, NetworkError>
}

class EditOrAddAddressServicesRepository: EditOrAddAddressServicesServiceable {
        
    
    private var networkRequest: Requestable
    private var baseUrl: String
    private var endPoint: AddOrEditAddressEndPoints

    init(networkRequest: Requestable, baseUrl: String, endPoint: AddOrEditAddressEndPoints) {
        self.networkRequest = networkRequest
        self.baseUrl = baseUrl
        self.endPoint = endPoint
    }

    func fetchLocatuionsNickNames(request: SaveAddressRequestModel) -> AnyPublisher<SaveAddressResponseModel, NetworkError> {
        
        let endPoint = AddOrEditAddressRequestBuilder.getLocationsNickNames(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl , endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    func saveAddress(request: SaveAddressRequestModel) -> AnyPublisher<SaveAddressResponseModel, NetworkingLayer.NetworkError> {
        
        let endPoint = AddOrEditAddressRequestBuilder.saveAddress(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl , endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    func getAllAddresses(request: RegisterLocationRequest) -> AnyPublisher<GetAllAddressesResponse, NetworkError> {
        
        let endPoint = AddOrEditAddressRequestBuilder.getAllAddresses(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl , endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    
    func removeAddresse(request: RemoveAddressRequestModel) -> AnyPublisher<RemoveAddressResponseModel, NetworkingLayer.NetworkError> {
        
        let endPoint = AddOrEditAddressRequestBuilder.removeAddress(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl , endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }
    func saveDefaultAddresse(request: RemoveAddressRequestModel) -> AnyPublisher<RemoveAddressResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = AddOrEditAddressRequestBuilder.removeAddress(request: request)
        let request = endPoint.createRequest(baseUrl: self.baseUrl , endPoint: self.endPoint)
        
        return self.networkRequest.request(request)
    }

}
