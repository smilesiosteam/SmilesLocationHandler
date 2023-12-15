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
import GooglePlaces

public class LocationServicesViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    public enum Input {
        case reverseGeoCodeToGetCompleteAddress(latitude: String, longitude: String)
        case locationReverseGeocodingFromOSMCoordinates(coordinates: CLLocationCoordinate2D, format: OSMResponseType)
        case searchLocation(text: String, isFromGoogle: Bool)
        case getLocationDetails(locationId: String, isFromGoogle: Bool)
        case getPolyLine(origion: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, wayPoints: CLLocationCoordinate2D?)
    }
    
    public enum Output {
        case fetchAddressFromCoordinatesDidSucceed(response: SWGoogleAddressResponse)
        case fetchAddressFromCoordinatesDidFail(error: NetworkError?)
        
        case fetchAddressFromCoordinatesOSMDidSucceed(response: OSMLocationResponse)
        case fetchAddressFromCoordinatesOSMDidFail(error: NetworkError?)
        
        case searchLocationDidSucceed(response: [SearchedLocationDetails])
        case searchLocationDidFail(error: Error)
        
        case fetchLocationDetailsDidSucceed(locationDetails: SearchedLocationDetails)
        case fetchLocationDetailsDidFail(error: NetworkError?)
        
        case getPolylineDidSucceed(response: PolylineResponseModel)
        case getPolylineDidFail(error: NetworkError?)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension LocationServicesViewModel {
    
    public func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .reverseGeoCodeToGetCompleteAddress(let latitude, let longitude):
                self?.getAddressFromCoordinates(latitude: latitude, longitude: longitude)
            case .locationReverseGeocodingFromOSMCoordinates(let coordinates, let format):
                self?.getAddressFromCoordinatesOSM(coordinates: coordinates, format: format)
            case .searchLocation(let location, let isFromGoogle):
                if isFromGoogle {
                    self?.getAutoCompleteResultsFromGoogle(location: location)
                } else {
                    self?.getAutoCompleteResultsFromOSM(location: location)
                }
            case .getLocationDetails(let locationId, let isFromGoogle):
                if isFromGoogle {
                    self?.getLocationDetailsFromGoogle(locationId: locationId)
                } else {
                    self?.getLocationDetailsFromOSM(locationId: locationId)
                }
            case .getPolyLine(let origion, let destination, let wayPoints):
                self?.getPolyline(origion: origion, destination: destination, wayPoints: wayPoints)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension LocationServicesViewModel {
    
    private func getAddressFromCoordinates(latitude: String, longitude: String) {
        
        guard let key = Bundle.main.object(forInfoDictionaryKey: Constants.Keys.googleAppKey) as? String else {
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
    
    private func getAutoCompleteResultsFromGoogle(location: String) {
        
        let token = GMSAutocompleteSessionToken.init()
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient()
        
        placesClient.findAutocompletePredictions(fromQuery: location, filter: filter, sessionToken: token) { [weak self] (results, error) in
            if let error = error {
                self?.output.send(.searchLocationDidFail(error: error))
            }
            var searchResults = [SearchedLocationDetails]()
            if let results = results {
                for result in results {
                    let location = SearchedLocationDetails(addressId: result.placeID,
                                                           title: result.attributedPrimaryText.string,
                                                           subTitle: result.attributedSecondaryText?.string ?? "")
                    searchResults.append(location)
                }
            }
            self?.output.send(.searchLocationDidSucceed(response: searchResults))
        }
        
    }
    
    private func getAutoCompleteResultsFromOSM(location: String) {
        
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .getAutoCompleteResultsFromOSM(location: location, format: .json, limit: 5, addressDetails: false)
        )
        
        service.getAutoCompleteResultsFromOSM()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAddressFromCoordinatesOSMDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                var searchResults = [SearchedLocationDetails]()
                for result in response {
                    let location = SearchedLocationDetails(addressId: "\(result.getOSMType()?.urlParameter ?? "")\(result.osmId ?? 0)",
                                                           title: result.getFormattedTitle(),
                                                           subTitle: result.displayName ?? "")
                    searchResults.append(location)
                }
                self?.output.send(.searchLocationDidSucceed(response: searchResults))
            }
            .store(in: &cancellables)
        
    }
    
    private func getLocationDetailsFromGoogle(locationId: String) {
        
        guard let key = Bundle.main.object(forInfoDictionaryKey: Constants.Keys.googleAppKey) as? String else {
            output.send(.fetchLocationDetailsDidFail(error: nil))
            return
        }
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .getLocationDetailsFromGoogle(placeId: locationId, key: key)
        )
        
        service.getLocationDetailsFromGoogle()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchLocationDetailsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                if let result = response.result {
                    let locationDetails = SearchedLocationDetails(latitude: result.geometry?.location?.lat ?? 0, longitude: result.geometry?.location?.lng ?? 0, formattedAddress: result.formattedAddress)
                    self?.output.send(.fetchLocationDetailsDidSucceed(locationDetails: locationDetails))
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func getLocationDetailsFromOSM(locationId: String) {
        
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .getLocationDetailsFromOSM(osmId: locationId, format: .json)
        )
        
        service.getLocationDetailsFromOSM()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchLocationDetailsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                if let location = response[safe: 0]?.getLocation(), let address = response[safe: 0]?.displayName {
                    let locationDetails = SearchedLocationDetails(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, formattedAddress: address)
                    self?.output.send(.fetchLocationDetailsDidSucceed(locationDetails: locationDetails))
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func getPolyline(origion: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, wayPoints: CLLocationCoordinate2D?) {
        
        guard let key = Bundle.main.object(forInfoDictionaryKey: Constants.Keys.googleAppKey) as? String else {
            output.send(.fetchAddressFromCoordinatesDidFail(error: nil))
            return
        }
        
        let service = LocationServicesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .getPolyline(origion: origion, destination: destination, wayPoints: wayPoints, key: key)
        )
        
        service.getPolyline()
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.getPolylineDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.getPolylineDidSucceed(response: response))
            }
            .store(in: &cancellables)
        
    }
    
}
