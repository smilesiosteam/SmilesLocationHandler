import Foundation
import Combine
import CoreLocation
import UIKit
import SmilesUtilities
import AnalyticsSmiles

public protocol SmilesLocationHandlerDelegate: AnyObject {
    func getUserLocationWith(locationName:String, andLocationNickName:String)
    func showPopupForLocationSetting()
    func searchBtnTappedOnToolTip()
    func locationUpdatedSuccessfully()
}

public class SmilesLocationHandler {
    
    enum Input {
        case registerUserLocation(location: CLLocation?)
        case getUserCurrentLocation
        case getPlaceFromLocation(isUpdated: Bool = false)
        case updateUserLocation(userInfo: NSDictionary?, request: RegisterLocationRequest)
    }
    
    enum Output {
        case fetchUserCurrentLocationDidSucceed(response: CLLocation?)
        case registerUserLocationDidSucceed(response: RegisterLocationResponse , location : CLLocation?)
        case registerUserLocationDidFail(error: Error)
        case fetchPlaceFromLocationDidSucceed(response: String, isUpdated: Bool)
        case fetchPlaceFromLocationDidFail(error: Error, isUpdated: Bool)
        case updateUserLocationDidSucceed(response: RegisterLocationResponse)
        case updateUserLocationDidFail(error: Error)
    }
    
    
    // MARK: -- Variables
    private let locationsViewModel = LocationsViewModel()
    private var locationsUseCaseInput :PassthroughSubject<LocationsViewModel.Input, Never> = .init()
    
    // MARK: -- Variables
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private var userLocation: CLLocation?
    var locationName = ""
    var locationNickName = ""
    public var fireEvent: ((String) -> Void)?
    public var showLocationToolTip: (() -> Void)?
    public var dismissLocationToolTip: (() -> Void)?
    
    public var toolTipForLocationShown: Bool = false
    public weak var smilesLocationHandlerDelegate : SmilesLocationHandlerDelegate?
    
    init() {
        locationsViewModel.fireEvent = fireEvent
    }
    
    public convenience init(controller:UIViewController?, isFirstLaunch: Bool = false){
        self.init()
        
        
        LocationManager.shared.delegate = self
        self.bind(to: self.locationsViewModel)
        
        if let location = LocationStateSaver.getLocationInfo(), !(location.locationId?.isEmpty ?? true){
            if !AppCommonMethods.isGuestUser {
                getSavedLocation(isFirstLaunch: isFirstLaunch)
            } else {
                getLocation()
            }
        }else{
            getLocation()
        }
        
    }
    
}

extension SmilesLocationHandler {
    public func detectBtnTapped() {
        self.hideToolTip()
        LocationManager.shared.getLocation { location, _ in
            if let currentLocation = location {
                self.updateUserLocation(currentLocation, isUpdated: true)
            } else {
                self.smilesLocationHandlerDelegate?.showPopupForLocationSetting()
            }
        }
    }
    
    public func searchBtnTapped() {
        self.hideToolTip()
        self.smilesLocationHandlerDelegate?.searchBtnTappedOnToolTip()
    }
}



//MARK: Functions
extension SmilesLocationHandler{
    func getLocation(){
        self.getUserCurrentLocation()
    }
    
    func updateUserLocationRequest(_ request: RegisterLocationRequest) {
        self.locationsUseCaseInput.send(.updateUserLocation(userInfo: nil,request: request))
    }
    
    func displayLocationName(_ locationName: String) {
        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
    }
    
    
    public func locationUpdatedManually(_ notification: Notification) {
        if let userInfo = notification.userInfo as NSDictionary? {
            self.locationsUseCaseInput.send(.updateUserLocation(userInfo: userInfo,request: nil))
        }
    }
    
    func updateUserLocation(_ location: CLLocation?, isUpdated: Bool) {
        
        if let userLocation = location {
            self.userLocation = userLocation
            self.locationsUseCaseInput.send(.getPlaceFromLocation(isUpdated: true))
            
            if isUpdated {
                let userLocationInfo = RegisterLocationRequest()
                if let userInfo = LocationStateSaver.getLocationInfo() {
                    userLocationInfo.userInfo = userInfo
                }
                userLocationInfo.userInfo?.latitude = String(userLocation.coordinate.latitude)
                userLocationInfo.userInfo?.longitude = String(userLocation.coordinate.longitude)
                
                userLocationInfo.userInfo?.locationId = nil
                userLocationInfo.userInfo?.location = nil
                userLocationInfo.userInfo?.isLocationUpdated = nil
                userLocationInfo.userInfo?.mambaId = nil
                userLocationInfo.userInfo?.cityId = nil
                userLocationInfo.userInfo?.nickName = nil
                
                updateUserLocationRequest(userLocationInfo)
            }
        } else {
            locationName = ""
            locationNickName = "SetLocationKey".localizedString
            self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        }
    }
    
    func updatedLocationToBeSaved(isUpdated:Bool ,_ userLocation: CLLocation){
        
        if isUpdated {
            let userLocationInfo = RegisterLocationRequest()
            if let userInfo = LocationStateSaver.getLocationInfo() {
                userLocationInfo.userInfo = userInfo
            }
            userLocationInfo.userInfo?.latitude = String(userLocation.coordinate.latitude)
            userLocationInfo.userInfo?.longitude = String(userLocation.coordinate.longitude)
            
            self.updateUserLocationRequest(userLocationInfo)
        }else{
            
            self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: LocationStateSaver.getLocationInfo()?.location ?? "", andLocationNickName: locationNickName)
        }
    }
    
    fileprivate func updatePreviousSavedLocation() {
        if let savedLocation = LocationStateSaver.getLocationInfo() {
            let latitude = Double(savedLocation.latitude.asStringOrEmpty()).asDoubleOrEmpty()
            let longitude = Double(savedLocation.longitude.asStringOrEmpty()).asDoubleOrEmpty()
            self.userLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            self.updateUserLocation(self.userLocation, isUpdated: false)
        }
    }
    
    func getSavedLocation(isFirstLaunch: Bool = false) {
        if isFirstLaunch {
            LocationManager.shared.getLocation { [weak self] location, _ in
                if let _ = location {
                    self?.fireEvent?("location_enabled")
                    self?.updateUserLocation(location, isUpdated: true)
                }
                else {
                    self?.fireEvent?("location_disabled")
                    self?.updatePreviousSavedLocation()
                }
            }
        } else {
            updatePreviousSavedLocation()
        }
    }
    
    func registerUserLocationSuccess(response: RegisterLocationResponse , location:CLLocation?){
        if let userInfo = response.userInfo {
            fireEvent?("location_registered_success")
            LocationStateSaver.saveLocationInfo(userInfo)
            
            // Get CLLocation from lat & long from userInfo response
            if let locationId = userInfo.locationId, !locationId.isEmpty, locationId != "0" {
                
                let latitude = Double(userInfo.latitude.asStringOrEmpty()).asDoubleOrEmpty()
                let longitude = Double(userInfo.longitude.asStringOrEmpty()).asDoubleOrEmpty()
                let userLocation = CLLocation(latitude: latitude, longitude: longitude)
                
                if !AppCommonMethods.isGuestUser {
                    if let shouldUpdate = userInfo.isLocationUpdated, !shouldUpdate {
                        self.updateUserLocation(userLocation, isUpdated: false)
                    }
                    else {
                        self.updateUserLocation(CLLocation(latitude: location?.coordinate.latitude ?? 0.0, longitude: location?.coordinate.longitude ?? 0.0), isUpdated: true)
                    }
                } else {
                    if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
                        self.updateUserLocation(CLLocation(latitude: lat, longitude: lon), isUpdated: true)
                    } else {
                        self.updateUserLocation(CLLocation(latitude: 25.194985, longitude: 55.278414), isUpdated: true)
                    }
                    
                }
            }
            else {
                self.updateUserLocation(nil, isUpdated: false)
            }
        } else {
            self.updateUserLocation(nil, isUpdated: false)
        }
        
        if let responseMsg = response.responseMsg, !responseMsg.isEmpty {
            fireEvent?("location_registered_fail")
        }
    }
    
    func registerUserLocationFail(){
        fireEvent?("location_registered_fail")
        self.updateUserLocation(nil, isUpdated: false)
    }
    
    func updateUserLocationSucceeded(response : RegisterLocationResponse) {
        
        fireEvent?("location_updated_success")
        LocationStateSaver.saveLocationInfo(response.userInfo)
        
        GlobalUserLocation.shared.latitude = response.userInfo?.latitude
        GlobalUserLocation.shared.longitude = response.userInfo?.longitude
        GlobalUserLocation.shared.locationId = response.userInfo?.locationId
        
        //        locationName = LocationStateSaver.getLocationInfo()?.location ?? ""
        //        locationNickName = response.userInfo?.nickName ?? locationNickName
        //
        //
        //        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        
        self.locationsUseCaseInput.send(.getPlaceFromLocation(isUpdated: true))
        
        
        if let _ = response.userInfo {
            fireEvent?("location_updated_success")
            self.smilesLocationHandlerDelegate?.locationUpdatedSuccessfully()
            
        }
    }
    
    
    func showToolTip() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if !(self.toolTipForLocationShown) {
                self.showLocationToolTip?()
                self.toolTipForLocationShown = true
            }
        }
    }
    
    func hideToolTip() {
        UIView.animate(withDuration: 0.2) {
            self.dismissLocationToolTip?()
            self.toolTipForLocationShown = false
        }
    }
}


//MARK:LocationUpdateProtocol
extension SmilesLocationHandler: LocationUpdateProtocol {
    public func locationDidUpdateToLocation(location: CLLocation?, placemark: CLPlacemark?) {
        userLocation = location
        if let placemark = placemark {
            self.displayLocationName((placemark.name ?? "") + ", " + (placemark.country ?? ""))
        }
        showToolTip()
        
    }
}


extension SmilesLocationHandler{
    func getUserCurrentLocation() {
        LocationManager.shared.getLocation { [weak self] location, _ in
            if let _ = location {
                self?.fireEvent?("location_enabled")
            }
            else {
                self?.fireEvent?("location_disabled")
            }
            self?.fetchUserCurrentLocationDidSucceed(location: location)
        }
    }
    
    func fetchUserCurrentLocationDidSucceed(location: CLLocation?){
        self.locationsUseCaseInput.send(.registerUserLocation(location: location))
    }
}




//MARK: -- Binding
extension SmilesLocationHandler{
    func bind(to locationsViewModel: LocationsViewModel) {
        locationsUseCaseInput = PassthroughSubject<LocationsViewModel.Input, Never>()
        let output = locationsViewModel.transform(input: locationsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchPlaceFromLocationDidSucceed(response: let place, isUpdated: _):
                    print(place)
                    self?.locationName = place
                    if let nickname = LocationStateSaver.getLocationInfo()?.nickName{
                        self?.locationNickName = nickname
                    }
                    self?.displayLocationName(place)
                    
                case .fetchPlaceFromLocationDidFail(error: let error,isUpdated: _):
                    print(error.localizedDescription)
                    
                case .updateUserLocationDidSucceed(response: let response):
                    self?.updateUserLocationSucceeded(response: response)
                    
                case .updateUserLocationDidFail(error: let error):
                    print(error.localizedDescription)
                    
                case .registerUserLocationDidSucceed(response: let response, location: let location):
                    self?.registerUserLocationSuccess(response: response, location: location)
                    
                case .registerUserLocationDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.registerUserLocationFail()
                }
            }.store(in: &cancellables)
    }
}
