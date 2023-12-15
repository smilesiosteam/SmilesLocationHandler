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

class AddOrEditAddressViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getLocationsNickName
        case getLocationName(lat: String, long: String)
        case saveAddress(address: Address?)
    }
    
    enum Output {
        case fetchLocationsNickNameDidSucceed(response: SaveAddressResponseModel)
        case fetchLocationsNickNameDidFail(error: NetworkError?)
        
        case saveAddressDidSucceed(response: SaveAddressResponseModel)
        case saveAddressDidFail(error: NetworkError?)
        
        case fetchLocationNameDidSucceed(response: String)
        case fetchLocationNameDidFail(error: NetworkError?)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let addressOperationViewModel = AddressOperationViewModel()
    private var setLocationViewModel = SetLocationViewModel()
    private var setLocationInput: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    
    // MARK: - ViewModels -
    private var addressOperationUseCaseInput: PassthroughSubject<AddressOperationViewModel.Input,Never> = .init()
}

// MARK: - INPUT. View event methods
extension AddOrEditAddressViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getLocationsNickName:
                self?.bind(to: self?.addressOperationViewModel ?? AddressOperationViewModel())
                self?.addressOperationUseCaseInput.send(.getLocationsNickName)
            case .getLocationName(let lat, let long):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.setLocationInput.send(.getLocationName(coordinates:CLLocation(latitude: Double(lat) ?? 0.0, longitude: Double(long) ?? 0.0)))
            case .saveAddress(let address):
                self?.bind(to: self?.addressOperationViewModel ?? AddressOperationViewModel())
                self?.addressOperationUseCaseInput.send(.saveAddress(address: address))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension AddOrEditAddressViewModel {
    
     func bind(to viewModel: AddressOperationViewModel) {
         addressOperationUseCaseInput = PassthroughSubject<AddressOperationViewModel.Input, Never>()
         let output = addressOperationViewModel.transform(input: addressOperationUseCaseInput.eraseToAnyPublisher())
         output
             .sink { [weak self] event in
                 switch event {
                 case .fetchLocationsNickNameDidSucceed(let nickNameResponse):
                     print(nickNameResponse)
                     self?.output.send(.fetchLocationsNickNameDidSucceed(response: nickNameResponse))
                 case .fetchLocationsNickNameDidFail(let error):
                     self?.output.send(.fetchLocationsNickNameDidFail(error: error))
                 case .saveAddressDidSucceed(response: let response):
                     self?.output.send(.saveAddressDidSucceed(response: response))
                 case .saveAddressDidFail(error: let error):
                     self?.output.send(.saveAddressDidFail(error: error))
                 case .fetchAllAddressDidSucceed(response: _):
                     break
                 case .fetchAllAddressDidFail(error: _):
                     break
                 case .removeAddressDidSucceed(response: _):
                     break
                 case .removeAddressDidFail(error: _):
                     break
                 }
             }.store(in: &cancellables)
    }
    
    private func bind(to setLocationViewModel: SetLocationViewModel) {
        setLocationInput = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = setLocationViewModel.transform(input: setLocationInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchLocationNameDidSucceed(let name):
                    self?.output.send(.fetchLocationNameDidSucceed(response: name))
                case .fetchLocationNameDidFail(let error):
                    self?.output.send(.fetchLocationNameDidFail(error: error))
                default: break
                }
            }.store(in: &cancellables)
    }
       
}
