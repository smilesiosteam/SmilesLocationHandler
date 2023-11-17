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
        case confirmUserLocation(selectedCity: GetCitiesModel)

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
        }
    }
    
}
