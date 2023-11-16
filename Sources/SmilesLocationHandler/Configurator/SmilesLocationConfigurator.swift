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

    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case .createDetectLocationPopup(let viewModel):
            return SmilesLocationDetectViewController(viewModel)
        case .setLocationPopUp:
            let vc = SetLocationPopupViewController()
            return vc
        }
    }
    
}
