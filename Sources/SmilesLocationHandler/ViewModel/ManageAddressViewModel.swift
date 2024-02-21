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
        case updateLocationToMamba(location: CLLocation)
        case saveAddress(address: Address?)
        case reverseGeocodeLatitudeAndLongitudeForAddress(location: CLLocation)
    }
    
    enum Output {
        case fetchAllAddressDidSucceed(response: GetAllAddressesResponse)
        case fetchAllAddressDidFail(error: NetworkError?)
        
        case removeAddressDidSucceed(response: RemoveAddressResponseModel)
        case removeAddressDidFail(error: NetworkError?)
        
        case getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case getUserLocationDidFail(error: NetworkError)
        
        case saveAddressDidSucceed(response: SaveAddressResponseModel)
        case saveAddressDidFail(error: NetworkError?)
        
        case fetchAddressFromCoordinatesDidSucceed(address: String)
        case fetchAddressFromCoordinatesDidFail(error: String?)
        
        case updateUserLocationDidSucceed(response : RegisterLocationResponse)
        case updateUserLocationDidFail(error: NetworkError)
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
            case .reverseGeocodeLatitudeAndLongitudeForAddress(let location):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                if !Constants.switchToOpenStreetMap {
                    self?.setLocationInput.send(.reverseGeocodeLatitudeAndLongitudeForAddress(coordinates: location.coordinate))
                } else {
                    self?.setLocationInput.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: location.coordinate, format: .json))
                }
            case .updateLocationToMamba(location: let location):
                self?.handleFoodMambaCalls(location: location)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleFoodMambaCalls(location: CLLocation) {
        
        if let _ = LocationStateSaver.getLocationInfo()?.locationId {
            self.bind(to: self.setLocationViewModel)
            self.setLocationInput.send(.updateUserLocation(location: location, withUserInfo: false))
        } else {
            self.setLocationInput.send(.registerUserLocation(location: location))
        }
        
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
                case .fetchAddressFromCoordinatesDidSucceed(let response):
                    if let formatedAddress = response.lines?.joined(separator: ", ") {
                        self?.output.send(.fetchAddressFromCoordinatesDidSucceed(address: formatedAddress))
                    } else {
                        self?.output.send(.fetchAddressFromCoordinatesDidFail(error: nil))
                    }
                case .fetchAddressFromCoordinatesDidFail(let error):
                    self?.output.send(.fetchAddressFromCoordinatesDidFail(error: error))
                case .fetchAddressFromCoordinatesOSMDidSucceed(let response):
                    if let address = response.displayName {
                        self?.output.send(.fetchAddressFromCoordinatesDidSucceed(address: address))
                    } else {
                        self?.output.send(.fetchAddressFromCoordinatesDidFail(error: nil))
                    }
                case .fetchAddressFromCoordinatesOSMDidFail(let error):
                    self?.output.send(.fetchAddressFromCoordinatesDidFail(error: error?.localizedDescription))
                case .registerUserLocationDidSucceed(let response, _):
                    self?.output.send(.updateUserLocationDidSucceed(response: response))
                case .registerUserLocationDidFail(let error):
                    self?.output.send(.updateUserLocationDidFail(error: error))
                case .updateUserLocationDidSucceed(let response):
                    self?.output.send(.updateUserLocationDidSucceed(response: response))
                case .updateUserLocationDidFail(let error):
                    self?.output.send(.updateUserLocationDidFail(error: error))
                default: break
                }
            }.store(in: &cancellables)
    }
}
