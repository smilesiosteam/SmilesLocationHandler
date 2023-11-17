//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import CoreLocation

class LocationServicesViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case reverseGeoCodeToGetCompleteAddress(latitude: String, longitude: String)
        case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
    }
    
    enum Output {
        case fetchAddressFromCoordinatesDidSucceed(response: SWGoogleAddressResponse)
        case fetchAddressFromCoordinatesDidFail(error: Error?)
        
        case fetchAddressFromCoordinatesOSMDidSucceed(response: OSMLocationResponse)
        case fetchAddressFromCoordinatesOSMDidFail(error: Error?)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension LocationServicesViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .reverseGeoCodeToGetCompleteAddress(let latitude, let longitude):
                self?.getAddressFromCoordinates(latitude: latitude, longitude: longitude)
            case .locationReverseGeocodingFromOSMCoordinates(let coordinates, let format):
                self?.getAddressFromCoordinatesOSM(coordinates: coordinates, format: format)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension LocationServicesViewModel {
    
    private func getAddressFromCoordinates(latitude: String, longitude: String) {
        
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GoogleAppKey") as? String else {
            output.send(.fetchAddressFromCoordinatesDidFail(error: nil))
            return
        }
        
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .reverseGeoCodeToGetCompleteAddress(latLong: "\(latitude),\(longitude)", key: key)
        )
        
        service.reverseGeoCodeToGetCompleteAddress()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAddressFromCoordinatesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchAddressFromCoordinatesDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
    private func getAddressFromCoordinatesOSM(coordinates: CLLocationCoordinate2D, format: OSMResponseType) {
        
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: format)
        )
        
        service.locationReverseGeocodingFromOSMCoordinates()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAddressFromCoordinatesOSMDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchAddressFromCoordinatesOSMDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
}
