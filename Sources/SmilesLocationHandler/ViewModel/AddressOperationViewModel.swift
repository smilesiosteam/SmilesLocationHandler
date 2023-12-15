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
        case removeAddress(address_id: String?)
    }
    
    enum Output {
        case fetchLocationsNickNameDidSucceed(response: SaveAddressResponseModel)
        case fetchLocationsNickNameDidFail(error: NetworkError?)
        
        case fetchAllAddressDidSucceed(response: GetAllAddressesResponse)
        case fetchAllAddressDidFail(error: NetworkError?)
        
        case removeAddressDidSucceed(response: RemoveAddressResponseModel)
        case removeAddressDidFail(error: NetworkError?)
        
        case saveAddressDidSucceed(response: SaveAddressResponseModel)
        case saveAddressDidFail(error: NetworkError?)
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
            let requestUserInfo = AppUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            requestUserInfo.locationId = userInfo.locationId
            request.userInfo = requestUserInfo
        }
        let service = ManageAddressRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: ManageAddressEndPoints.getLocationsNickName
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
       
        let request = SaveAddressRequestModel(address: address)
        
        let service = ManageAddressRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: ManageAddressEndPoints.saveAddress
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
            request.locationInfo = userInfo
        }
        let service = ManageAddressRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: ManageAddressEndPoints.getAllAddresses
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
    
    private func removeAddress(address_id: String?) {
        let request = RemoveAddressRequestModel()
        request.addressId = address_id
        if let userInfo = LocationStateSaver.getLocationInfo() {
            let requestUserInfo = SmilesUserInfo()
            requestUserInfo.mambaId = userInfo.mambaId
            request.userInformation = requestUserInfo
        }
        
        let service = ManageAddressRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: ManageAddressEndPoints.removeAddress
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
       
}
