import Foundation
import Combine
import CoreLocation
import UIKit
import SmilesUtilities
import AnalyticsSmiles

public enum LocationCheckEntryPoint {
    case fromVertical
    case fromFood
    case fromBAU
}


public protocol LocationToolTipViewDelegate: AnyObject {
    func searchBtnTapped()
    func detectBtnTapped()
}

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
    var controllerType : LocationCheckEntryPoint = .fromBAU
    var isFirstLaunch = false
    
    public var fireEvent: ((String) -> Void)?
    public var showLocationToolTip: (() -> Void)?
    public var dismissLocationToolTip: (() -> Void)?
    
    public var toolTipForLocationShown: Bool = false
    public weak var smilesLocationHandlerDelegate : SmilesLocationHandlerDelegate?
    
    
    init() {
        locationsViewModel.fireEvent = fireEvent
    }
    
    public convenience init(delegate: SmilesLocationHandlerDelegate?, isFirstLaunch: Bool = false , controllerType: LocationCheckEntryPoint = .fromBAU){
        self.init()
        self.controllerType = controllerType
        self.isFirstLaunch = isFirstLaunch
        self.smilesLocationHandlerDelegate = delegate
        LocationManager.shared.delegate = self
        self.bind(to: self.locationsViewModel)
        LocationManager.shared.startUpdatingLocation()
        
    }
}

//MARK: LocationToolTipViewDelegate
extension SmilesLocationHandler: LocationToolTipViewDelegate{
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
    
    func updateUserLocationRequest(_ location: CLLocation) {
        self.locationsUseCaseInput.send(.updateUserLocation(location: location, withUserInfo: false))
    }
    
    func displayLocationName(_ locationName: String) {
        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
    }
    
    
    public func locationUpdatedManually(_ notification: Notification) {
        if let userInfo = notification.userInfo as NSDictionary?, let locationModel = userInfo["location"] as? SearchLocationResponseModel {
            self.locationsUseCaseInput.send(.updateUserLocation(location: CLLocation(latitude: locationModel.lat ?? 0, longitude: locationModel.long ?? 0), withUserInfo: true))
        }
    }
    
    func updateUserLocation(_ location: CLLocation?, isUpdated: Bool) {
        
        if let userLocation = location {
            self.userLocation = userLocation
            self.locationsUseCaseInput.send(.getPlaceFromLocation(isUpdated: true))
            if isUpdated {
                updateUserLocationRequest(userLocation)
            }
        } else {
            locationName = ""
            locationNickName = "SetLocationKey".localizedString
            self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        }
    }
    
    
    func updateUserLocationForVertical(_ locationLat:String, locationLong:String, isUpdated: Bool) {
        
        if isUpdated, let lat = Double(locationLat), let long = Double(locationLong) {
            updateUserLocationRequest(CLLocation(latitude: lat, longitude: long))
        }
    }
    
    
    
    func updatedLocationToBeSaved(isUpdated:Bool ,_ userLocation: CLLocation){
        
        if isUpdated {
            self.updateUserLocationRequest(userLocation)
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
                    self?.fireEvent?(Constants.AnalyticsEvent.locationEnabled)
                    self?.updateUserLocation(location, isUpdated: true)
                }
                else {
                    self?.fireEvent?(Constants.AnalyticsEvent.locationDisabled)
                    self?.updatePreviousSavedLocation()
                }
            }
        } else {
            updatePreviousSavedLocation()
        }
    }
    
    func registerUserLocationSuccess(response: RegisterLocationResponse , location:CLLocation?){
        if let userInfo = response.userInfo {
            fireEvent?(Constants.AnalyticsEvent.locationRegistered)
            LocationStateSaver.saveLocationInfo(userInfo)
            //
            //            // Get CLLocation from lat & long from userInfo response
            //            if let locationId = userInfo.locationId, !locationId.isEmpty, locationId != "0" {
            //
            //                let latitude = Double(userInfo.latitude.asStringOrEmpty()).asDoubleOrEmpty()
            //                let longitude = Double(userInfo.longitude.asStringOrEmpty()).asDoubleOrEmpty()
            //                let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            //
            //                if !AppCommonMethods.isGuestUser {
            //                    if let shouldUpdate = userInfo.isLocationUpdated, !shouldUpdate {
            //                        self.updateUserLocation(userLocation, isUpdated: false)
            //                    }
            //                    else {
            //                        self.updateUserLocation(CLLocation(latitude: location?.coordinate.latitude ?? 0.0, longitude: location?.coordinate.longitude ?? 0.0), isUpdated: true)
            //                    }
            //                } else {
            //                    if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
            //                        self.updateUserLocation(CLLocation(latitude: lat, longitude: lon), isUpdated: true)
            //                    } else {
            //                        self.updateUserLocation(CLLocation(latitude: 25.194985, longitude: 55.278414), isUpdated: true)
            //                    }
            //
            //                }
            //            }
            //            else {
            //                self.updateUserLocation(nil, isUpdated: false)
            //            }
            //        } else {
            //            self.updateUserLocation(nil, isUpdated: false)
            //        }
            //
            //        if let responseMsg = response.responseMsg, !responseMsg.isEmpty {
            //            fireEvent?("location_registered_fail")
            
            self.smilesLocationHandlerDelegate?.locationUpdatedSuccessfully()
        }
    }
    
    func registerUserLocationFail(){
        fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
        self.updateUserLocation(nil, isUpdated: false)
    }
    
    func updateUserLocationSucceeded(response : RegisterLocationResponse) {
        
        fireEvent?(Constants.AnalyticsEvent.locationUpdated)
        LocationStateSaver.saveLocationInfo(response.userInfo)
        
        GlobalUserLocation.shared.latitude = response.userInfo?.latitude
        GlobalUserLocation.shared.longitude = response.userInfo?.longitude
        GlobalUserLocation.shared.locationId = response.userInfo?.locationId
        
        self.locationsUseCaseInput.send(.getPlaceFromLocation(isUpdated: true))
        
        
        if let _ = response.userInfo {
            fireEvent?(Constants.AnalyticsEvent.locationUpdated)
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
    public func locationIsAllowedByUser(isAllowed: Bool) {
        print("locationIsAllowedByUser \(isAllowed)")
        
        if isAllowed{
            LocationManager.shared.destroyLocationManager()
            switch self.controllerType{
            case .fromBAU:
                if isFirstLaunch{
                    getLocation()
                }else{
                    if let location = LocationStateSaver.getLocationInfo(),let loc = location.location, !loc.isEmpty{
                        locationName = loc
                        locationNickName = location.nickName ?? "---"
                        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
                    }else{
                        locationName = ""
                        locationNickName = "SetLocationKey".localizedString
                        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
                    }
                }
            case .fromFood, .fromVertical:
                print("")
                if let location = LocationStateSaver.getLocationInfo(),let _ = location.locationId{
                    print("call update service for mamba")
                    updateUserLocationForVertical(location.latitude ?? "0", locationLong: location.longitude ?? "0", isUpdated: true)
                }else{
                    getLocation()
                }
            }
        }
    }
    
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
                self?.fireEvent?(Constants.AnalyticsEvent.locationEnabled)
            }
            else {
                self?.fireEvent?(Constants.AnalyticsEvent.locationDisabled)
            }
            self?.fetchUserCurrentLocationDidSucceed(location: location)
        }
    }
    
    //    func fetchUserCurrentLocationDidSucceed(location: CLLocation?){
    //        self.locationsUseCaseInput.send(.registerUserLocation(location: location))
    //    }
    
    func fetchUserCurrentLocationDidSucceed(location: CLLocation?){
        self.locationsUseCaseInput.send(.getUserLocation(location: location))
    }
    
    
    func getUserLocationDidSucceed(response: RegisterLocationResponse,location: CLLocation?){
        if let userInfo = response.userInfo {
            if controllerType == .fromFood{
                self.locationsUseCaseInput.send(.registerUserLocation(location: location))
            }else{
                fireEvent?(Constants.AnalyticsEvent.locationRegistered)
                LocationStateSaver.saveLocationInfo(userInfo)
                locationName = userInfo.location ?? "---"
                locationNickName = userInfo.nickName ?? "---"
                self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
            }
        }
        
        if let responseMsg = response.responseMsg, !responseMsg.isEmpty {
            fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
            locationName = ""
            locationNickName = "SetLocationKey".localizedString
            self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        }
    }
    
    func getUserLocationFail(){
        fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
        locationName = ""
        locationNickName = "SetLocationKey".localizedString
        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
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
                case .fetchPlaceFromLocationDidSucceed(response: let place):
                    print(place)
                    self?.locationName = place
                    if let nickname = LocationStateSaver.getLocationInfo()?.nickName{
                        self?.locationNickName = nickname
                    }
                    self?.displayLocationName(place)
                    
                case .fetchPlaceFromLocationDidFail(error: let error):
                    print(error?.localizedDescription ?? "")
                    
                case .updateUserLocationDidSucceed(response: let response):
                    self?.updateUserLocationSucceeded(response: response)
                    
                case .updateUserLocationDidFail(error: let error):
                    print(error.localizedDescription)
                    
                case .registerUserLocationDidSucceed(response: let response, location: let location):
                    self?.registerUserLocationSuccess(response: response, location: location)
                    
                case .registerUserLocationDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.registerUserLocationFail()
                    
                case .getUserLocationDidSucceed(response:  let response,location: let location):
                    self?.getUserLocationDidSucceed(response: response,location: location)
                    
                case .getUserLocationDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.getUserLocationFail()
                    
                }
            }.store(in: &cancellables)
    }
}
