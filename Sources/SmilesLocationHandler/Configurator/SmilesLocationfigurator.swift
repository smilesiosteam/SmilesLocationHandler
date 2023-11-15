//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 14/11/2023.
//

import Foundation
import UIKit

struct SmilesLocationfigurator {
    
    public enum ConfiguratorType {
        case createDetectLocationPopup( viewModel: DetectLocationPopupViewModel?)
    }
    
    static func create(type: ConfiguratorType) -> UIViewController {
        switch type {
        case.createDetectLocationPopup( let viewModel):
            let vc = SmilesDetectLocationPopUp()
            vc.configure(with: viewModel ?? nil)
            return vc
        }
    }
    
}
