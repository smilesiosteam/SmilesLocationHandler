//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import UIKit
import SmilesUtilities
import CoreLocation

@objcMembers
 public final class SmilesLocationRouter: NSObject {
    
    // MARK: - Singleton Instance
    public var navigationController: UINavigationController?
    public static let shared = SmilesLocationRouter()
    
    // MARK: - Methods
    
    public func showDetectLocationPopup(from viewController: UIViewController, controllerType: LocationPopUpType, switchToOpenStreetMap: Bool = false) {
        
        Constants.switchToOpenStreetMap = switchToOpenStreetMap
        let viewModel = DetectLocationPopupViewModelFactory.createViewModel(for: controllerType)
        if let detectLocationPopup = SmilesLocationConfigurator.create(type: .createDetectLocationPopup(viewModel)) as? SmilesLocationDetectViewController {
            setActionsForControllerType(popupViewController: detectLocationPopup, controllerType: controllerType)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.present(detectLocationPopup, animated: true)
        }
        
    }
    func presentSetLocationPopUp(on viewController: UIViewController) {
        
        let setLocationPopUp = SmilesLocationConfigurator.create(type: .setLocationPopUp) as! SetLocationPopupViewController
        setLocationPopUp.modalPresentationStyle = .overFullScreen
        viewController.present(setLocationPopUp, animated: true)
        
    }
    
   public func pushManageAddressesViewController(with navigationController: UINavigationController) {
        let vc = SmilesLocationConfigurator.create(type: .manageAddresses)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private Methods
    private func setActionsForControllerType(popupViewController: SmilesLocationDetectViewController, controllerType: LocationPopUpType) {
        popupViewController.setDetectLocationAction {
            self.handleDetectLocationAction(for: controllerType)
        }
        popupViewController.setSearchLocationAction {
            self.handleSearchLocationAction(for: controllerType)
        }
    }
    
    private func handleDetectLocationAction(for controllerType: LocationPopUpType) {
        switch controllerType {
        case .detectLocation, .automaticallyDetectLocation:
            LocationManager.shared.showPopupForSettings()
        case .deleteWorkAddress:
            // Handle detect location action for DeleteWorkAddress
            break
        }
    }
    
    private func handleSearchLocationAction(for controllerType: LocationPopUpType) {
        switch controllerType {
        case .detectLocation:
            if let topViewController = navigationController?.topViewController {
                presentSetLocationPopUp(on: topViewController)
            }
        case .automaticallyDetectLocation:
            if let navigationController = navigationController {
                self.pushUpdateLocationViewController(with: navigationController)
            }
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
    
     func pushAddOrEditAddressViewController(with navigationController: UINavigationController, addressObject: Address? = nil, selectedLocation: SearchLocationResponseModel? = nil, delegate: ConfirmLocationDelegate?) {
        if let vc = SmilesLocationConfigurator.create(type: .addOrEditAddress(addressObject: addressObject, selectedLocation: selectedLocation, delegate: delegate)) as? AddOrEditAddressViewController {
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
        }
    }

    public func pushUpdateLocationViewController(with navigationController: UINavigationController, delegate: UpdateUserLocationDelegate? = nil) {
        let vc = SmilesLocationConfigurator.create(type: .updateLocation(delegate: delegate))
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
     func pushConfirmUserLocationVC(selectedCity: GetCitiesModel?, sourceScreen: ConfirmLocatiuonSourceScreen = .addAddressViewController, delegate: ConfirmLocationDelegate?) {
        
         let vc = SmilesLocationConfigurator.create(type: .confirmUserLocation(selectedCity: selectedCity, sourceScreen: sourceScreen, delegate: delegate)) as! ConfirmUserLocationViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
     func pushSearchLocationVC(isFromUpdateLocation: Bool = false, locationSelected: @escaping((SearchedLocationDetails) -> Void)) {
        
         let vc = SmilesLocationConfigurator.create(type: .searchLocation(isFromUpdateLocation: isFromUpdateLocation, locationSelected: locationSelected)) as! SearchLocationViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func popVC() {
        navigationController?.popViewController(animated: true)
    }
    
}
