//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import Foundation
import Combine
import NetworkingLayer
import CoreLocation

class LocationsViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getPlaceFromLocation(isUpdated:Bool)
        case updateUserLocation(location: CLLocation, withUserInfo: Bool)
        case registerUserLocation(location: CLLocation?)
        case getUserLocation(location: CLLocation?)
    }
    
    enum Output {
        case fetchPlaceFromLocationDidSucceed(response: String)
        case fetchPlaceFromLocationDidFail(error: Error?)
        
        case updateUserLocationDidSucceed(response : RegisterLocationResponse)
        case updateUserLocationDidFail(error: Error)
        
        case registerUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case registerUserLocationDidFail(error: Error)
        
        case getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case getUserLocationDidFail(error: Error)
        
    }
    
    // MARK: -- Variables
    private var setLocationViewModel = SetLocationViewModel()
    private var setLocationInput: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    var fireEvent: ((String) -> Void)?
    
}

// MARK: - INPUT. View event methods
extension LocationsViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getPlaceFromLocation:
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.getLocationName()
                
            case .updateUserLocation(let location, let withUserInfo):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.setLocationInput.send(.updateUserLocation(location: location, withUserInfo: withUserInfo))
                
            case .registerUserLocation(location: let location):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.setLocationInput.send(.registerUserLocation(location: location))
                
            case .getUserLocation(location: let location):
                self?.bind(to: self?.setLocationViewModel ?? SetLocationViewModel())
                self?.setLocationInput.send(.getUserLocation(location: location))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func getLocationName() {
        
        if let location = LocationStateSaver.getLocationInfo() {
            if let latitude = location.latitude, let longitude = location.longitude {
                let userLocation = CLLocation(latitude: Double(latitude).asDoubleOrEmpty(), longitude: Double(longitude).asDoubleOrEmpty())
                setLocationInput.send(.getLocationName(coordinates: userLocation))
            } else{
                output.send(.fetchPlaceFromLocationDidFail(error:NetworkError.noResponse("Lat long not found")))
            }
        } else {
            output.send(.fetchPlaceFromLocationDidFail(error:NetworkError.noResponse("Lat long not found")))
        }
        
    }
    
}

// MARK: - VIEMODEL BINDING -
extension LocationsViewModel {
    
    func bind(to setLocationViewModel: SetLocationViewModel) {
        setLocationInput = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = setLocationViewModel.transform(input: setLocationInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .registerUserLocationDidSucceed(let response, let location):
                    self?.output.send(.registerUserLocationDidSucceed(response: response,location: location))
                case .registerUserLocationDidFail(let error):
                    self?.fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
                    self?.output.send(.registerUserLocationDidFail(error: error))
                case .updateUserLocationDidSucceed(let response):
                    self?.output.send(.updateUserLocationDidSucceed(response: response))
                case .updateUserLocationDidFail(let error):
                    self?.output.send(.updateUserLocationDidFail(error: error))
                case .getUserLocationDidSucceed(let response, let location):
                    self?.output.send(.getUserLocationDidSucceed(response: response, location: location))
                case .getUserLocationDidFail(let error):
                    self?.fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
                    self?.output.send(.getUserLocationDidFail(error: error))
                case .fetchLocationNameDidSucceed(let name):
                    self?.output.send(.fetchPlaceFromLocationDidSucceed(response: name))
                case .fetchLocationNameDidFail(let error):
                    self?.output.send(.fetchPlaceFromLocationDidFail(error: error))
                default: break
                }
            }.store(in: &cancellables)
    }
    
}

