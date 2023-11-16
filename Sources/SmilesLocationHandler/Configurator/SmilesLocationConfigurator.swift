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

        case createDetectLocationPopup(controller: ControllerType)
        case setLocationPopUp

    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case .createDetectLocationPopup(let controllerType):
            let viewModel = DetectLocationPopupViewModelFactory.createViewModel(for: controllerType)
            let vc = SmilesDetectLocationPopUp()
            vc.configure(with: viewModel)
            return vc
        case .setLocationPopUp:
            let vc = SetLocationPopupViewController()
            return vc
        }
    }
    
}
