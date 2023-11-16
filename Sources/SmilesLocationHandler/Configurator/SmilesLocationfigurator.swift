//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 14/11/2023.
//

import Foundation
import UIKit

struct SmilesLocationfigurator {
    
    enum ConfiguratorType {
        case createDetectLocationPopup(controller: ControllerType)
    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case .createDetectLocationPopup(let controllerType):
            let viewModel = DetectLocationPopupViewModelFactory.createViewModel(for: controllerType)
            let vc = SmilesDetectLocationPopUp()
            vc.configure(with: viewModel)
            return vc
        }
    }
    
}
