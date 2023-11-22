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
        case removeAddress(address_id: Int?)
        
    }
    
    enum Output {
        case fetchAllAddressDidSucceed(response: GetAllAddressesResponse)
        case fetchAllAddressDidFail(error: Error?)
        
        case removeAddressDidSucceed(response: RemoveAddressResponseModel)
        case removeAddressDidFail(error: Error?)
        
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let addressOperationViewModel = AddressOperationViewModel()
    
    // MARK: - ViewModels -
    private var addressOperationUseCaseInput: PassthroughSubject<AddressOperationViewModel.Input,Never> = .init()
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
                 case .fetchLocationsNickNameDidSucceed(response: _):
                     break
                 case .fetchLocationsNickNameDidFail(error: _):
                     break
                 case .saveAddressDidSucceed(response: _):
                     break
                 case .saveAddressDidFail(error: _):
                     break
                 }
             }.store(in: &cancellables)
    }
}
