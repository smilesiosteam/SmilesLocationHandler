//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import CoreLocation

class SetLocationViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getCities
        case reverseGeocodeLatitudeAndLongitudeForAddress(latitude: String, longitude: String)
        case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
        case searchLocation(location: String, isFromGoogle: Bool)
        case getLocationDetails(locationId: String, isFromGoogle: Bool)
    }
    
    enum Output {
        case fetchCitiesDidSucceed(response: GetCitiesResponse)
        case fetchCitiesDidFail(error: Error)
        
        case fetchAddressFromCoordinatesDidSucceed(response: SWGoogleAddressResponse)
        case fetchAddressFromCoordinatesDidFail(error: Error?)
        
        case fetchAddressFromCoordinatesOSMDidSucceed(response: OSMLocationResponse)
        case fetchAddressFromCoordinatesOSMDidFail(error: Error?)
        
        case searchLocationDidSucceed(response: [SearchLocationResponseModel])
        case searchLocationDidFail(error: Error)
        
        case fetchLocationDetailsDidSucceed(response: SearchedLocationDetails)
        case fetchLocationDetailsDidFail(error: Error?)
    }
    
    // MARK: -- Variables
    private var locationServicesViewModel = LocationServicesViewModel()
    private var locationServicesInput: PassthroughSubject<LocationServicesViewModel.Input, Never> = .init()
    
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension SetLocationViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCities:
                self?.getCities()
            case .reverseGeocodeLatitudeAndLongitudeForAddress(let latitude, let longitude):
                self?.bind(to: self?.locationServicesViewModel ?? LocationServicesViewModel())
                self?.locationServicesInput.send(.reverseGeoCodeToGetCompleteAddress(latitude: latitude, longitude: longitude))
            case .locationReverseGeocodingFromOSMCoordinates(let coordinates, let format):
                self?.bind(to: self?.locationServicesViewModel ?? LocationServicesViewModel())
                self?.locationServicesInput.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: format))
            case .searchLocation(let location, let isFromGoogle):
                self?.bind(to: self?.locationServicesViewModel ?? LocationServicesViewModel())
                self?.locationServicesInput.send(.searchLocation(text: location, isFromGoogle: isFromGoogle))
            case .getLocationDetails(let locationId, let isFromGoogle):
                self?.bind(to: self?.locationServicesViewModel ?? LocationServicesViewModel())
                self?.locationServicesInput.send(.getLocationDetails(locationId: locationId, isFromGoogle: isFromGoogle))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension SetLocationViewModel {
    
    private func getCities() {
        let getCitiesRequest = GetCitiesRequest(isGuestUser: AppCommonMethods.isGuestUser)
        let service = SetLocationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: .getCities
        )
        
        service.getCitiesService(request: getCitiesRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCitiesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchCitiesDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - VIEMODEL BINDING -
extension SetLocationViewModel {
    
    func bind(to locationServicesViewModel: LocationServicesViewModel) {
        locationServicesInput = PassthroughSubject<LocationServicesViewModel.Input, Never>()
        let output = locationServicesViewModel.transform(input: locationServicesInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchAddressFromCoordinatesDidSucceed(let response):
                    self?.output.send(.fetchAddressFromCoordinatesDidSucceed(response: response))
                case .fetchAddressFromCoordinatesDidFail(let error):
                    self?.output.send(.fetchAddressFromCoordinatesDidFail(error: error))
                case .fetchAddressFromCoordinatesOSMDidSucceed(let response):
                    self?.output.send(.fetchAddressFromCoordinatesOSMDidSucceed(response: response))
                case .fetchAddressFromCoordinatesOSMDidFail(let error):
                    self?.output.send(.fetchAddressFromCoordinatesOSMDidFail(error: error))
                case .searchLocationDidSucceed(let response):
                    self?.output.send(.searchLocationDidSucceed(response: response))
                case .searchLocationDidFail(let error):
                    self?.output.send(.searchLocationDidFail(error: error))
                case .fetchLocationDetailsDidSucceed(let locationDetails):
                    self?.output.send(.fetchLocationDetailsDidSucceed(response: locationDetails))
                case .fetchLocationDetailsDidFail(let error):
                    self?.output.send(.fetchLocationDetailsDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
}
