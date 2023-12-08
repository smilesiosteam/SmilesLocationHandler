import Foundation
import Combine
import CoreLocation
import UIKit
import SmilesUtilities
import AnalyticsSmiles

public enum LocationCheckEntryPoint {
    case fromVertical
    case fromFood
    case fromDashboard
}

public protocol SmilesLocationHandlerDelegate: AnyObject {
    func getUserLocationWith(locationName:String, andLocationNickName:String)
    func locationUpdatedSuccessfully()
}

public class SmilesLocationHandler {
    
    // MARK: - PROPERTIES -
    private let locationsViewModel = LocationsViewModel()
    private var locationsUseCaseInput :PassthroughSubject<LocationsViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var userLocation: CLLocation?
    private var locationName = ""
    private var locationNickName = ""
    private var controllerType : LocationCheckEntryPoint = .fromDashboard
    private var isFirstLaunch = false
    public var fireEvent: ((String) -> Void)?
    public weak var smilesLocationHandlerDelegate : SmilesLocationHandlerDelegate?
    static var isLocationEnabled = false
    
    // MARK: - INITIALIZERS -
    init() {
        locationsViewModel.fireEvent = fireEvent
    }
    
    public convenience init(delegate: SmilesLocationHandlerDelegate?, isFirstLaunch: Bool = false , controllerType: LocationCheckEntryPoint = .fromDashboard){
        self.init()
        self.controllerType = controllerType
        self.isFirstLaunch = isFirstLaunch
        self.smilesLocationHandlerDelegate = delegate
        self.bind(to: self.locationsViewModel)
        LocationManager.shared.delegate = self
        LocationManager.shared.startUpdatingLocation()
    }
    
    // MARK: - METHODS -
    private func updateUserLocationRequest(_ location: CLLocation) {
        self.locationsUseCaseInput.send(.updateUserLocation(location: location, withUserInfo: false))
    }
    
    private func setupSetLocationString() {
        
        locationName = ""
        locationNickName = "SetLocationKey".localizedString
        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        
    }
    
    
    private func updateUserLocationForVertical(_ locationLat:String, locationLong:String, isUpdated: Bool) {
        
        if isUpdated, let lat = Double(locationLat), let long = Double(locationLong) {
            updateUserLocationRequest(CLLocation(latitude: lat, longitude: long))
        }
        
    }
    
    private func getUserCurrentLocation() {
        LocationManager.shared.getLocation { [weak self] location, _ in
            if let _ = location {
                self?.fireEvent?(Constants.AnalyticsEvent.locationEnabled)
            }
            else {
                self?.fireEvent?(Constants.AnalyticsEvent.locationDisabled)
            }
            self?.locationsUseCaseInput.send(.getUserLocation(location: location))
        }
    }
    
}

// MARK: - LOCATION UPDATE DELEGATE -
extension SmilesLocationHandler: LocationUpdateProtocol {
    
    public func locationIsAllowedByUser(isAllowed: Bool) {
        
        debugPrint("locationIsAllowedByUser \(isAllowed)")
        SmilesLocationHandler.isLocationEnabled = isAllowed
        LocationManager.shared.destroyLocationManager()
        switch self.controllerType{
        case .fromDashboard:
            if isFirstLaunch {
                getUserCurrentLocation()
            } else {
                if let location = LocationStateSaver.getLocationInfo(),let loc = location.location, !loc.isEmpty{
                    locationName = loc
                    locationNickName = location.nickName ?? "---"
                    self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
                } else {
                    setupSetLocationString()
                }
            }
        case .fromFood, .fromVertical:
            if let location = LocationStateSaver.getLocationInfo() {
                if let _ = location.locationId {
                    debugPrint("call update service for mamba")
                    updateUserLocationForVertical(location.latitude ?? "0", locationLong: location.longitude ?? "0", isUpdated: true)
                } else {
                    guard let latitudeString = location.latitude, let latitude = Double(latitudeString),
                          let longitudeString = location.longitude, let longitude = Double(longitudeString) else { return }
                    self.locationsUseCaseInput.send(.registerUserLocation(location: CLLocation(latitude: latitude, longitude: longitude)))
                }
            }
        }
        
    }
    
    public func locationDidUpdateToLocation(location: CLLocation?, placemark: CLPlacemark?) {
        userLocation = location
        if let placemark = placemark {
            self.displayLocationName((placemark.name ?? "") + ", " + (placemark.country ?? ""))
        }
    }
    
}

// MARK: - VIEWMODEL BINDING -
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
                    
                case .registerUserLocationDidSucceed(response: let response, _):
                    self?.registerUserLocationSuccess(response: response)
                    
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

// MARK: - API RESPONSE HANDLING -
extension SmilesLocationHandler {
    
    private func displayLocationName(_ locationName: String) {
        self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
    }
    
    private func updateUserLocationSucceeded(response : RegisterLocationResponse) {
        
        fireEvent?(Constants.AnalyticsEvent.locationUpdated)
        LocationStateSaver.saveLocationInfo(response.userInfo, isFromMamba: true)
        if let userInfo = LocationStateSaver.getLocationInfo() {
            locationName = userInfo.location ?? ""
            locationNickName = userInfo.nickName ?? "---"
            self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
        }
        self.smilesLocationHandlerDelegate?.locationUpdatedSuccessfully()
        
    }
    
    private func registerUserLocationSuccess(response: RegisterLocationResponse){
        
        if let userInfo = response.userInfo {
            fireEvent?(Constants.AnalyticsEvent.locationRegistered)
            LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: true)
            if let userInfo = LocationStateSaver.getLocationInfo() {
                locationName = userInfo.location ?? ""
                locationNickName = userInfo.nickName ?? "---"
                self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
            }
            self.smilesLocationHandlerDelegate?.locationUpdatedSuccessfully()
        }
        
    }
    
    private func registerUserLocationFail() {
        fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
        setupSetLocationString()
    }
    
    private func getUserLocationDidSucceed(response: RegisterLocationResponse, location: CLLocation?) {
        
        if let userInfo = response.userInfo {
            if controllerType == .fromFood {
                self.locationsUseCaseInput.send(.registerUserLocation(location: location))
            } else{
                fireEvent?(Constants.AnalyticsEvent.locationRegistered)
                LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
                locationName = userInfo.location ?? ""
                locationNickName = userInfo.nickName ?? "---"
                self.smilesLocationHandlerDelegate?.getUserLocationWith(locationName: locationName, andLocationNickName: locationNickName)
            }
        }
        
        if let responseMsg = response.responseMsg, !responseMsg.isEmpty {
            fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
            setupSetLocationString()
        }
        
    }
    
    private func getUserLocationFail() {
        fireEvent?(Constants.AnalyticsEvent.locationRegistrationFailed)
        setupSetLocationString()
    }
    
}
