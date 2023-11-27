//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import UIKit
import NetworkingLayer
import CoreLocation
import SmilesUtilities

public class LocationBaseServices {
    
    let networkManager = NetworkManager()
    
    public static let shared = LocationBaseServices()
    
    public init() {}
    
    //MARK: - User Location Api's
    
    public func registerLocation(_ location: CLLocation?, completionHandler: @escaping (_ response: RegisterLocationResponse) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        
        let registerRequest = RegisterLocationRequest()
        registerRequest.isGuestUser = AppCommonMethods.isGuestUser
        registerRequest.userInfo = AppUserInfo()
        if !AppCommonMethods.isGuestUser {
            if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                registerRequest.userInfo?.latitude = String(lat)
                registerRequest.userInfo?.longitude = String(lon)
            } else {
                registerRequest.userInfo?.latitude = ""
                registerRequest.userInfo?.longitude = ""
            }
        } else {
            if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                registerRequest.userInfo?.latitude = String(lat)
                registerRequest.userInfo?.longitude = String(lon)
            } else {
                registerRequest.userInfo?.latitude = "25.194985"
                registerRequest.userInfo?.longitude = "55.278414"
            }
        }
        
        
        registerUserLocationRequest(request: registerRequest, completionHandler: { response in
            print(response)
            completionHandler(response)
        }) { error in
            print(error ?? "")
            failureBlock(error)
        }
    }
    
    private func registerUserLocationRequest(request: RegisterLocationRequest, completionHandler: @escaping (_ response: RegisterLocationResponse) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        let registerUserLocationRequest = LocationRouter.registerUserLocation(request: request)
        
        networkManager.executeRequest(for: RegisterLocationResponse.self, registerUserLocationRequest, successBlock: { response in
            
            switch response {
            case let .success(result):
                completionHandler(result)
                
            case let .failure(error):
                let errorModel = ErrorCodeConfiguration()
                errorModel.errorCode = (error as NSError).code
                errorModel.errorDescriptionEn = error.localizedDescription
                errorModel.errorDescriptionAr = error.localizedDescription
                failureBlock(errorModel)
            }
            
        }) { error in
            failureBlock(error)
        }
    }
    
    public func updateUserLocationRequest(request: RegisterLocationRequest, completionHandler: @escaping (_ response: RegisterLocationResponse) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        request.userInfo?.isLocationUpdated = false

        let updateUserLocationRequest = LocationRouter.updateUserLocation(request: request)
        
        networkManager.executeRequest(for: RegisterLocationResponse.self, updateUserLocationRequest, successBlock: { response in
            
            switch response {
            case let .success(result):
                completionHandler(result)
                
            case let .failure(error):
                let errorModel = ErrorCodeConfiguration()
                errorModel.errorCode = (error as NSError).code
                errorModel.errorDescriptionEn = error.localizedDescription
                errorModel.errorDescriptionAr = error.localizedDescription
                failureBlock(errorModel)
            }
            
        }) { error in
            failureBlock(error)
        }
    }
    
    public func saveDefaultAddressRequest(request: RemoveAddressRequestModel, completionHandler: @escaping (_ response: RemoveAddressResponseModel) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        let saveDefaultAddressRequest = LocationRouter.saveDefaultAddress(request: request)
        
        networkManager.executeRequest(for: RemoveAddressResponseModel.self, saveDefaultAddressRequest, successBlock: { response in
            
            switch response {
            case let .success(result):
                completionHandler(result)
                
            case let .failure(error):
                let errorModel = ErrorCodeConfiguration()
                errorModel.errorCode = (error as NSError).code
                errorModel.errorDescriptionEn = error.localizedDescription
                errorModel.errorDescriptionAr = error.localizedDescription
                failureBlock(errorModel)
            }
            
        }) { error in
            failureBlock(error)
        }
    }
    
    public func getPlaceFromLocation(_ location: CLLocation?, completionHandler: @escaping (_ place: String) -> ()){
        
        if let userLocation = location{
            LocationManager.shared.reverseGeocoding = false
            
            LocationManager.shared.getReverseGeoCodedLocation(location: userLocation) { (location, placemark, error) in
                
                if let place = placemark{
                    LocationStateSaver.getLocationInfo()?.cityName = place.locality.asStringOrEmpty()
                    completionHandler((LocationStateSaver.getLocationInfo()?.location ?? "" )  + ", " + place.locality.asStringOrEmpty())
                }
                else{
                    completionHandler("")
                }
            }
        }
    }
    
    public func getNewPlaceLocationName(_ location: CLLocation?, completionHandler: @escaping (_ place: String) -> ()){
        
        if let userLocation = location{
            LocationManager.shared.reverseGeocoding = false
            
            LocationManager.shared.getReverseGeoCodedLocation(location: userLocation) { (location, placemark, error) in
                
                if let place = placemark {
                    completionHandler(place.subLocality.asStringOrEmpty()  + ", " + place.locality.asStringOrEmpty())
                }
                else{
                    completionHandler("")
                }
            }
        }
    }
    
    
    public func getUserLocation(_ location: CLLocation?, completionHandler: @escaping (_ response: RegisterLocationResponse) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        
        let registerRequest = RegisterLocationRequest()
        registerRequest.userInfo = AppUserInfo()
        if !AppCommonMethods.isGuestUser {
            if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                registerRequest.userInfo?.latitude = String(lat)
                registerRequest.userInfo?.longitude = String(lon)
            } else {
                registerRequest.userInfo?.latitude = ""
                registerRequest.userInfo?.longitude = ""
            }
        } else {
            if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                registerRequest.userInfo?.latitude = String(lat)
                registerRequest.userInfo?.longitude = String(lon)
            } else {
                registerRequest.userInfo?.latitude = "25.194985"
                registerRequest.userInfo?.longitude = "55.278414"
            }
        }
        
    
        getUserLocationRequest(request: registerRequest, completionHandler: { response in
            print(response)
            completionHandler(response)
        }) { error in
            print(error ?? "")
            failureBlock(error)
        }
    }
    
    
    
    private func getUserLocationRequest(request: RegisterLocationRequest, completionHandler: @escaping (_ response: RegisterLocationResponse) -> (), failureBlock: @escaping (_ error: ErrorCodeConfiguration?) -> ()) {
        let registerUserLocationRequest = LocationRouter.getUserLocation(request: request)
        
        networkManager.executeRequest(for: RegisterLocationResponse.self, registerUserLocationRequest, successBlock: { response in
            
            switch response {
            case let .success(result):
                completionHandler(result)
                
            case let .failure(error):
                let errorModel = ErrorCodeConfiguration()
                errorModel.errorCode = (error as NSError).code
                errorModel.errorDescriptionEn = error.localizedDescription
                errorModel.errorDescriptionAr = error.localizedDescription
                failureBlock(errorModel)
            }
            
        }) { error in
            failureBlock(error)
        }
    }
    
    public  func startUpdatingLocation(){
        LocationManager.shared.getLocation { (location, error) in
            
        }
    }
}
