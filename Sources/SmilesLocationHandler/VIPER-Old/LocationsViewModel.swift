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
    
    let locationService = LocationBaseServices()
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getPlaceFromLocation(isUpdated:Bool)
        case updateUserLocation(userInfo: NSDictionary?, request: RegisterLocationRequest?)
        case registerUserLocation(location: CLLocation?)
        case getUserLocation(location: CLLocation?)
    }
    
    enum Output {
        case fetchPlaceFromLocationDidSucceed(response:String,isUpdated:Bool)
        case fetchPlaceFromLocationDidFail(error: Error,isUpdated:Bool)
        
        case updateUserLocationDidSucceed(response : RegisterLocationResponse)
        case updateUserLocationDidFail(error: Error)
        
        case registerUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case registerUserLocationDidFail(error: Error)
        
        case getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?)
        case getUserLocationDidFail(error: Error)
        
    }
    
    // MARK: -- Variables
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
            case .getPlaceFromLocation(let isUpdated):
                self?.getPlaceFromLocation(isUpdated: isUpdated)
                
            case .updateUserLocation(userInfo: let userInfo, request: let request):
                self?.updateUserLocation(userInfo: userInfo, request: request)
                
            case .registerUserLocation(location: let location):
                self?.registerUserLocation(location)
                
            case .getUserLocation(location: let location):
                self?.getUserLocation(location)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func getPlaceFromLocation(isUpdated:Bool){
        if let location = LocationStateSaver.getLocationInfo() {
            if let latitude = location.latitude, let longitude = location.longitude {
                let userLocation = CLLocation(latitude: Double(latitude).asDoubleOrEmpty(), longitude: Double(longitude).asDoubleOrEmpty())
                
                locationService.getPlaceFromLocation(userLocation) {[weak self]  place in
                    if !place.isEmpty {
                        self?.output.send(.fetchPlaceFromLocationDidSucceed(response: place, isUpdated: isUpdated))
                    }else{
                        self?.output.send(.fetchPlaceFromLocationDidFail(error:NetworkError.noResponse("Place is empty"), isUpdated: isUpdated))
                        
                    }
                }
            }else{
                
                output.send(.fetchPlaceFromLocationDidFail(error:NetworkError.noResponse("Lat long not found"),isUpdated: isUpdated))
            }
            
        } else {
            output.send(.fetchPlaceFromLocationDidFail(error:NetworkError.noResponse("Lat long not found"),isUpdated: isUpdated))
        }
    }
    
    func updateUserLocation(userInfo: NSDictionary?, request: RegisterLocationRequest?){
        if let userInfo  = userInfo{
            if let locationModel = userInfo["location"] as? SearchLocationResponseModel {
                let userLocationInfo = RegisterLocationRequest()
                if let userInfo = LocationStateSaver.getLocationInfo() {
                    userLocationInfo.userInfo = userInfo
                }
                
                userLocationInfo.userInfo?.latitude = "\(locationModel.lat ?? 0.0)"
                userLocationInfo.userInfo?.longitude = "\(locationModel.long ?? 0.0)"

                callUpdateLocationService(userLocationInfo)
            }else{
                output.send(.updateUserLocationDidFail(error:NetworkError.noResponse("model is not as search")))
            }
        }else if let request = request{
            callUpdateLocationService(request)
        }else{
            output.send(.updateUserLocationDidFail(error:NetworkError.noResponse("model is not as search")))
        }
    }
    
    private func callUpdateLocationService(_ userLocationInfo: RegisterLocationRequest) {
        locationService.updateUserLocationRequest(request: userLocationInfo) { [weak self] response in
            self?.output.send(.updateUserLocationDidSucceed(response: response))
        } failureBlock: { [weak self] error in
            self?.output.send(.updateUserLocationDidFail(error:NetworkError.noResponse("no response")))
        }
    }
    
    
    func registerUserLocation(_ location: CLLocation?) {
        
        locationService.registerLocation(location) { [weak self] response in
            self?.output.send(.registerUserLocationDidSucceed(response: response,location: location))
        } failureBlock: { [weak self] error in
            self?.fireEvent?("location_registered_fail")
            self?.output.send(.registerUserLocationDidFail(error:NetworkError.noResponse("location_registered_fail")))
        }
    }
    
    
    func getUserLocation(_ location: CLLocation?) {
        
        locationService.getUserLocation(location) { [weak self] response in
            self?.output.send(.getUserLocationDidSucceed(response: response,location: location))
        } failureBlock: { [weak self] error in
            self?.fireEvent?("location_registered_fail")
            self?.output.send(.getUserLocationDidFail(error:NetworkError.noResponse("location_registered_fail")))
        }
        
    }
}
        
        
    
