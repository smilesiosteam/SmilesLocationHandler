//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 14/11/2023.
//

import Foundation
import UIKit
import CoreLocation

struct SmilesLocationConfigurator {
    
    enum ConfiguratorType {
        
        case createDetectLocationPopup(_ viewModel: DetectLocationPopupViewModel?)
        case setLocationPopUp
        case manageAddresses
        case addOrEditAddress
        case confirmUserLocation(selectedCity: GetCitiesModel?, locationHandler: ((SearchLocationResponseModel) -> Void)?)
        case searchLocation(locationSelected: ((SearchedLocationDetails) -> Void))
        case updateLocation(delegate: UpdateUserLocationDelegate?)
        
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
        case .confirmUserLocation(let selectedCity, let locationHandler):
            let vc = ConfirmUserLocationViewController(selectedCity: selectedCity)
            vc.locationHandler = locationHandler
            return vc
        case .searchLocation(let locationSelected):
            let vc = SearchLocationViewController(locationSelected: locationSelected)
            return vc
        case .addOrEditAddress:
            let vc = AddOrEditAddressViewController()
            return vc
        case .updateLocation(let delegate):
            let vc = UpdateLocationViewController(delegate: delegate)
            return vc
        }
    }
    
}
