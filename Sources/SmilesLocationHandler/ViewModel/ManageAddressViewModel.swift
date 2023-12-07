//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 22/11/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import CoreLocation

class ManageAddressViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getAllAddress
        case removeAddress(address_id: String?)
        case getUserLocation(location: CLLocation?)
        case saveAddress(address: Address?)
    }
    
    enum Output {
        case fetchAllAddressDidSucceed(response: GetAllAddressesResponse)
        case fetchAllAddressDidFail(error: Error?)
        
        case removeAddressDidSucceed(response: RemoveAddressResponseModel)
        case removeAddressDidFail(error: Error?)
        
        case getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case getUserLocationDidFail(error: Error)
        
        case saveAddressDidSucceed(response: SaveAddressResponseModel)
        case saveAddressDidFail(error: Error?)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - ViewModels -
    private let addressOperationViewModel = AddressOperationViewModel()
    private var addressOperationUseCaseInput: PassthroughSubject<AddressOperationViewModel.Input,Never> = .init()
    private var setLocationViewModel = SetLocationViewModel()
    private var setLocationInput: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
}

// MARK: - INPUT. View event methods
extension ManageAddressViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getAllAddress:
                self?.bind(to: self?.addressOperationViewModel ?? AddressOperationViewModel())
                self?.addressOperationUseCaseInput.send(.getAllAddress)
            case .removeAddress(address_id: let id):
                self?.bind(to: self?.addressOperationViewModel ?? AddressOperationViewModel())
                self?.addressOperationUseCaseInput.send(.removeAddress(address_id: id))
            case .getUserLocation(location: let location):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.setLocationInput.send(.getUserLocation(location: location))
            case .saveAddress(let address):
                self?.bind(to: self?.addressOperationViewModel ?? AddressOperationViewModel())
                self?.addressOperationUseCaseInput.send(.saveAddress(address: address))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension ManageAddressViewModel {
    
     func bind(to viewModel: AddressOperationViewModel) {
         addressOperationUseCaseInput = PassthroughSubject<AddressOperationViewModel.Input, Never>()
         let output = addressOperationViewModel.transform(input: addressOperationUseCaseInput.eraseToAnyPublisher())
         output
             .sink { [weak self] event in
                 switch event {
                 case .fetchAllAddressDidSucceed(let response):
                     self?.output.send(.fetchAllAddressDidSucceed(response: response))
                 case .fetchAllAddressDidFail(let error):
                     self?.output.send(.fetchAllAddressDidFail(error: error))
                 case .removeAddressDidSucceed(response: let response):
                     self?.output.send(.removeAddressDidSucceed(response: response))
                 case .removeAddressDidFail(error: let error):
                     self?.output.send(.removeAddressDidFail(error: error))
                 case .saveAddressDidSucceed(response: let response):
                     self?.output.send(.saveAddressDidSucceed(response: response))
                 case .saveAddressDidFail(error: let error):
                     self?.output.send(.saveAddressDidFail(error: error))
                 default: break
                 }
             }.store(in: &cancellables)
    }
    
    func bind(to setLocationViewModel: SetLocationViewModel) {
        setLocationInput = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = setLocationViewModel.transform(input: setLocationInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .getUserLocationDidSucceed(let response, let location):
                    self?.output.send(.getUserLocationDidSucceed(response: response, location: location))
                case .getUserLocationDidFail(let error):
                    self?.output.send(.getUserLocationDidFail(error: error))
                default: break
                }
            }.store(in: &cancellables)
    }
}
