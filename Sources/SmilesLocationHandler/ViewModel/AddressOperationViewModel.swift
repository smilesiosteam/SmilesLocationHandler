//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import CoreLocation


class AddressOperationViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getLocationsNickName
        case saveAddress(address: Address?)
        case getAllAddress
        case removeAddress(address_id: Int?)
        case saveDefaultAddress(_ location: SearchLocationResponseModel)
    }
    
    enum Output {
        case fetchLocationsNickNameDidSucceed(response: SaveAddressResponseModel)
        case fetchLocationsNickNameDidFail(error: Error?)
        
        case fetchAllAddressDidSucceed(response: GetAllAddressesResponse)
        case fetchAllAddressDidFail(error: Error?)
        
        case removeAddressDidSucceed(response: RemoveAddressResponseModel)
        case removeAddressDidFail(error: Error?)
        
        case saveAddressDidSucceed(response: SaveAddressResponseModel)
        case saveAddressDidFail(error: Error?)
        
        case saveDefaultAddressDidSucceed(response: RemoveAddressResponseModel)
        case saveDefaultAddressDidFail(error: Error?)
        
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension AddressOperationViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getLocationsNickName:
                self?.getLocationsNickName()
                
            case .saveAddress(address: let address):
                self?.saveAddress(address: address)
                
            case .getAllAddress:
                self?.getAllAddress()

            case .removeAddress(address_id: let address_id):
                self?.removeAddress(address_id: address_id)
            case .saveDefaultAddress(let location):
                self?.saveDefaultAddress(location: location)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension AddressOperationViewModel {
    
    private func getLocationsNickName() {
        let request = SaveAddressRequestModel()
        request.address = nil
        if let userInfo = LocationStateSaver.getLocationInfo() {
            let requestUserInfo = SmilesUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            requestUserInfo.locationId = userInfo.locationId
            request.userInfo = requestUserInfo
        }
        let service = EditOrAddAddressServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: AddOrEditAddressEndPoints.getLocationsNickName
        )
        service.fetchLocatuionsNickNames(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchLocationsNickNameDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchLocationsNickNameDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    private func saveAddress(address: Address?) {
        let request = SaveAddressRequestModel()
        
        if let userInfo = LocationStateSaver.getLocationInfo() {
            let requestUserInfo = SmilesUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            requestUserInfo.locationId = userInfo.locationId
            request.userInfo = requestUserInfo
        }
        request.address = address
        let service = EditOrAddAddressServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: AddOrEditAddressEndPoints.saveAddress
        )
        service.saveAddress(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.saveAddressDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.saveAddressDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    private func getAllAddress(isGuestUser: Bool = false) {
        let request = RegisterLocationRequest()
        request.isGuestUser = isGuestUser
        if let userInfo = LocationStateSaver.getLocationInfo() {
            request.userInfo = userInfo
        }
        let service = EditOrAddAddressServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: AddOrEditAddressEndPoints.getAllAddresses
        )
        
        service.getAllAddresses(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAllAddressDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchAllAddressDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
    private func removeAddress(address_id: Int?) {
        let request = RemoveAddressRequestModel()
        request.addressId = address_id
        if let userInfo = LocationStateSaver.getLocationInfo() {
            let requestUserInfo = SmilesUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            request.userInfo = requestUserInfo
        }
        
        let service = EditOrAddAddressServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: AddOrEditAddressEndPoints.removeAddress
        )
        
        service.removeAddresse(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.removeAddressDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.removeAddressDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    private func saveDefaultAddress(location: SearchLocationResponseModel) {
        
        let request = RemoveAddressRequestModel()
        if let userInfo = LocationStateSaver.getLocationInfo() {
            let requestUserInfo = SmilesUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            request.userInfo = requestUserInfo
        }
        request.addressId = Int(location.addressId ?? "")
        
        let service = EditOrAddAddressServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: AddOrEditAddressEndPoints.saveDefaultAddress
        )
        
        service.saveDefaultAddresse(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.saveDefaultAddressDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.saveDefaultAddressDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
       
}
