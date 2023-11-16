//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import UIKit

public final class SmilesLocationRouter {
    
    // MARK: - Singleton Instance
    
    public static let shared = SmilesLocationRouter()
    
    // MARK: - Methods
    
    public func showDetectLocationPopup(from viewController: UIViewController, controllerType: ControllerType) {
        if let popupViewController = SmilesLocationfigurator.create(type: .createDetectLocationPopup(controller: controllerType)) as? SmilesDetectLocationPopUp {
            setActionsForControllerType(popupViewController: popupViewController, controllerType: controllerType)
            viewController.present(popupViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func setActionsForControllerType(popupViewController: SmilesDetectLocationPopUp, controllerType: ControllerType) {
        popupViewController.setDetectLocationAction {
            self.handleDetectLocationAction(for: controllerType)
        }
        popupViewController.setSearchLocationAction {
            self.handleSearchLocationAction(for: controllerType)
        }
    }
    
    private func handleDetectLocationAction(for controllerType: ControllerType) {
        switch controllerType {
        case .detectLocation:
            // Handle detect location action for DetectLocation
            break
        case .automaticallyDetectLocation:
            // Handle detect location action for AutomaticallyDetectLocation
            break
        case .deleteWorkAddress:
            // Handle detect location action for DeleteWorkAddress
            break
        }
    }
    
    private func handleSearchLocationAction(for controllerType: ControllerType) {
        switch controllerType {
        case .detectLocation:
            // Handle search location action for DetectLocation
            break
        case .automaticallyDetectLocation:
            // Handle search location action for AutomaticallyDetectLocation
            break
        case .deleteWorkAddress:
            // Handle search location action for DeleteWorkAddress
            break
        }
    }
    
    // MARK: - Navigation Methods
    
    private func navigateToSearchLocation() {
        // Implement navigation logic to search location
    }
    
    private func navigateToDetectLocation() {
        // Implement navigation logic to detect location
    }
}
