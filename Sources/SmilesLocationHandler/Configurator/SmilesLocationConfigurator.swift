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
        
        case createDetectLocationPopup(_ viewModel: DetectLocationPopupViewModel?)
        case setLocationPopUp
        case manageAddresses
        case addOrEditAddress(addressObject: Address? = nil, selectedLocation: SearchLocationResponseModel? = nil, delegate: ConfirmLocationDelegate?)
        case confirmUserLocation(selectedCity: GetCitiesModel?, sourceScreen: ConfirmLocatiuonSourceScreen, delegate: ConfirmLocationDelegate?)
        case searchLocation(isFromUpdateLocation: Bool, locationSelected: ((SearchedLocationDetails) -> Void))
        case updateLocation
        
    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case .createDetectLocationPopup(let viewModel):
            return SmilesLocationDetectViewController(viewModel)
        case .setLocationPopUp:
            let vc = SetLocationPopupViewController()
            return vc
        case .manageAddresses:
            return SmilesManageAddressesViewController()
        case .confirmUserLocation(let selectedCity, let sourceScreen, let delegate):
            let vc = ConfirmUserLocationViewController(selectedCity: selectedCity, sourceScreen: sourceScreen, delegate: delegate)
            return vc
        case .searchLocation(let isFromUpdateLocation, let locationSelected):
            let vc = SearchLocationViewController(isFromUpdateLocation: isFromUpdateLocation, locationSelected: locationSelected)
            return vc
        case .addOrEditAddress(let addressObject, let selectedLocation, let delegate):
            let vc = AddOrEditAddressViewController(addressObj: addressObject, selectedLocation: selectedLocation, delegate: delegate)
            return vc
        case .updateLocation:
            let vc = UpdateLocationViewController()
            return vc
        }
    }
    
}
