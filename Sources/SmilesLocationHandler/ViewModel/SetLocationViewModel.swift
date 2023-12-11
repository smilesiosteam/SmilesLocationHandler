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
import SmilesBaseMainRequestManager

public class SetLocationViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    public enum Input {
        case getCities
        case reverseGeocodeLatitudeAndLongitudeForAddress(latitude: String, longitude: String)
        case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
        case searchLocation(location: String, isFromGoogle: Bool)
        case getLocationDetails(locationId: String, isFromGoogle: Bool)
        case registerUserLocation(location: CLLocation?)
        case updateUserLocation(location: CLLocation, withUserInfo: Bool)
        case getUserLocation(location: CLLocation? = nil)
        case getLocationName(coordinates: CLLocation)
    }
    
    public enum Output {
        case fetchCitiesDidSucceed(response: GetCitiesResponse)
        case fetchCitiesDidFail(error: Error)
        
        case fetchAddressFromCoordinatesDidSucceed(response: SWGoogleAddressResponse)
        case fetchAddressFromCoordinatesDidFail(error: Error?)
        
        case fetchAddressFromCoordinatesOSMDidSucceed(response: OSMLocationResponse)
        case fetchAddressFromCoordinatesOSMDidFail(error: Error?)
        
        case searchLocationDidSucceed(response: [SearchedLocationDetails])
        case searchLocationDidFail(error: Error)
        
        case fetchLocationDetailsDidSucceed(response: SearchedLocationDetails)
        case fetchLocationDetailsDidFail(error: Error?)
        
        case registerUserLocationDidSucceed(response: RegisterLocationResponse, location: CLLocation?)
        case registerUserLocationDidFail(error: Error)
        
        case updateUserLocationDidSucceed(response : RegisterLocationResponse)
        case updateUserLocationDidFail(error: Error)
        
        case getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case getUserLocationDidFail(error: Error)
        
        case fetchLocationNameDidSucceed(response: String)
        case fetchLocationNameDidFail(error: Error? = nil)
    }
    
    // MARK: -- Variables
    private var locationServicesViewModel = LocationServicesViewModel()
    private var locationServicesInput: PassthroughSubject<LocationServicesViewModel.Input, Never> = .init()
    
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension SetLocationViewModel {
    
    public func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
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
            case .registerUserLocation(let location):
                self?.registerUserLocation(location)
            case .updateUserLocation(let location, let withUserInfo):
                self?.updateUserLocation(location, withUserInfo: withUserInfo)
            case .getUserLocation(let location):
                self?.getUserLocation(location)
            case .getLocationName(let coordinates):
                self?.getLocationName(from: coordinates)
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
    
    private func registerUserLocation(_ location: CLLocation?) {
        
        let request = setupRegisterLocationRequest(location: location)
        
        let service = SetLocationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: .registerLocation
        )
        
        service.registerUserLocationService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(_):
                    self?.output.send(.registerUserLocationDidFail(error:NetworkError.noResponse("location_registered_fail")))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.registerUserLocationDidSucceed(response: response, location: location))
            }
            .store(in: &cancellables)
        
    }
    
    private func updateUserLocation(_ location: CLLocation, withUserInfo: Bool) {
        
        let request = RegisterLocationRequest()
        request.isGuestUser = AppCommonMethods.isGuestUser
        request.locationInfo = withUserInfo ? SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo : AppUserInfo()
        if AppCommonMethods.isGuestUser {
            request.locationInfo = AppUserInfo()
        }
        request.locationInfo?.latitude = String(location.coordinate.latitude)
        request.locationInfo?.longitude = String(location.coordinate.longitude)
        
        let service = SetLocationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: .updateUserLocation
        )
        
        service.updateUserLocationService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(_):
                    self?.output.send(.updateUserLocationDidFail(error:NetworkError.noResponse("no response")))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.updateUserLocationDidSucceed(response: response))
            }
            .store(in: &cancellables)
        
    }
    
    private func getUserLocation(_ location: CLLocation?) {
        
        let request = setupRegisterLocationRequest(location: location)
        
        let service = SetLocationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: .getUserLocation
        )
        
        service.getUserLocationService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(_):
                    self?.output.send(.getUserLocationDidFail(error:NetworkError.noResponse("location_registered_fail")))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                response.userInfo?.locationId = LocationStateSaver.getLocationInfo()?.locationId
                response.userInfo?.mambaId = LocationStateSaver.getLocationInfo()?.mambaId
                self?.output.send(.getUserLocationDidSucceed(response: response,location: location))
            }
            .store(in: &cancellables)
        
    }
    
    private func setupRegisterLocationRequest(location: CLLocation?) -> RegisterLocationRequest {
        
        let registerRequest = RegisterLocationRequest()
        registerRequest.isGuestUser = AppCommonMethods.isGuestUser
        registerRequest.locationInfo = AppCommonMethods.isGuestUser ? AppUserInfo() : SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo
        var latitude = AppCommonMethods.isGuestUser ? "25.194985" : ""
        var longitude = AppCommonMethods.isGuestUser ? "55.278414" : ""
        if let location {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        }
        if registerRequest.locationInfo == nil {
            registerRequest.locationInfo = AppUserInfo()
        }
        if !latitude.isEmpty, !longitude.isEmpty {
            registerRequest.locationInfo?.latitude = latitude
            registerRequest.locationInfo?.longitude = longitude
        } else {
            registerRequest.locationInfo = nil
        }
        return registerRequest
        
    }
    
    private func getLocationName(from location: CLLocation){
        
        LocationManager.shared.reverseGeocoding = false
        LocationManager.shared.getReverseGeoCodedLocation(location: location) { [weak self] (location, placemark, error) in
            if let place = placemark {
                self?.output.send(.fetchLocationNameDidSucceed(response: place.subLocality.asStringOrEmpty() + ", " + place.locality.asStringOrEmpty()))
            } else{
                self?.output.send(.fetchLocationNameDidFail())
            }
        }
        
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
                default: break
                }
            }.store(in: &cancellables)
    }
    
}
