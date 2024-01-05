//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 14/11/2023.
//

import Foundation
import UIKit
import CoreLocation
import SmilesUtilities

struct SmilesLocationConfigurator {
    
    enum ConfiguratorType {
        
        case createDetectLocationPopup(controllerType: LocationPopUpType, dismissed: (() -> Void)? = nil)
        case setLocationPopUp
        case manageAddresses(updateLocationDelegate: UpdateUserLocationDelegate?)
        case addOrEditAddress(addressObject: Address? = nil, selectedLocation: SearchLocationResponseModel? = nil, delegate: ConfirmLocationDelegate? = nil, updateLocationDelegate: UpdateUserLocationDelegate? = nil)
        case confirmUserLocation(selectedCity: GetCitiesModel?, sourceScreen: ConfirmLocationSourceScreen, delegate: ConfirmLocationDelegate?)
        case searchLocation(isFromFoodCart: Bool?, locationSelected: ((SearchedLocationDetails) -> Void))
        case updateLocation(delegate: UpdateUserLocationDelegate?, isFromFoodCart: Bool)
        
    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case .createDetectLocationPopup(let controllerType, let dismissed):
            return SmilesLocationDetectViewController(controllerType: controllerType, dismissed: dismissed)
        case .setLocationPopUp:
            let vc = SetLocationPopupViewController()
            return vc
        case .manageAddresses(let delegate):
            return SmilesManageAddressesViewController(delegate: delegate)
        case .confirmUserLocation(let selectedCity, let sourceScreen, let delegate):
            let vc = ConfirmUserLocationViewController(selectedCity: selectedCity, sourceScreen: sourceScreen, delegate: delegate)
            return vc
        case .searchLocation(let isFromFoodCart, let locationSelected):
            let vc = SearchLocationViewController(isFromFoodCart: isFromFoodCart, locationSelected: locationSelected)
            return vc
        case .addOrEditAddress(let addressObject, let selectedLocation, let delegate, let updateLocationDelegate):
            let vc = AddOrEditAddressViewController(addressObj: addressObject, selectedLocation: selectedLocation, delegate: delegate, updateLocationDelegate: updateLocationDelegate)
            return vc
        case .updateLocation(let delegate, let isFromFoodCart):
            let vc = UpdateLocationViewController(delegate: delegate, isFromFoodCart: isFromFoodCart)
            return vc
        }
    }
    
}
