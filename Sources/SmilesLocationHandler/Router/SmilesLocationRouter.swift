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
        let viewModel = DetectLocationPopupViewModelFactory.createViewModel(for: controllerType)
        if let detectLocationPopup = SmilesLocationConfigurator.create(type: .createDetectLocationPopup(viewModel)) as? SmilesLocationDetectViewController {
            setActionsForControllerType(popupViewController: detectLocationPopup, controllerType: controllerType)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.present(detectLocationPopup, animated: true)
        }
    }
    public func presentSetLocationPopUp(on viewController: UIViewController) {
        
        let setLocationPopUp = SmilesLocationConfigurator.create(type: .setLocationPopUp) as! SetLocationPopupViewController
        setLocationPopUp.modalPresentationStyle = .overFullScreen
        viewController.present(setLocationPopUp, animated: true)
        
    }
    // MARK: - Private Methods
    
    private func setActionsForControllerType(popupViewController: SmilesLocationDetectViewController, controllerType: ControllerType) {
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
