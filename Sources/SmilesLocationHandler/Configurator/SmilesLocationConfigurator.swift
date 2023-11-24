//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 14/11/2023.
//

import Foundation
import UIKit

struct SmilesLocationConfigurator {
    
    enum ConfiguratorType {
        
        case createDetectLocationPopup(_ viewModel: DetectLocationPopupViewModel?)
        case setLocationPopUp
        case manageAddresses
        case addOrEditAddress
        case confirmUserLocation(selectedCity: GetCitiesModel?)
        case searchLocation(locationSelected: ((SearchedLocationDetails) -> Void))
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
        case .confirmUserLocation(let selectedCity):
            let vc = ConfirmUserLocationViewController(selectedCity: selectedCity)
            return vc
        case .searchLocation(let locationSelected):
            let vc = SearchLocationViewController(locationSelected: locationSelected)
            return vc
        case .addOrEditAddress:
            let vc = AddOrEditAddressViewController()
            return vc
        case .updateLocation:
            let vc = UpdateLocationViewController()
            return vc
        }
    }
    
}
