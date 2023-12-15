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
        if let detectLocationPopup = SmilesLocationConfigurator.create(type: .createDetectLocationPopup(controllerType: controllerType)) as? SmilesLocationDetectViewController {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.present(detectLocationPopup, animated: true)
        }
        
    }
    func presentSetLocationPopUp() {
        
        guard let viewController = navigationController?.topViewController else { return }
        let setLocationPopUp = SmilesLocationConfigurator.create(type: .setLocationPopUp) as! SetLocationPopupViewController
        setLocationPopUp.modalPresentationStyle = .overFullScreen
        viewController.present(setLocationPopUp, animated: true)
        
    }
    
    public func pushManageAddressesViewController(with navigationController: UINavigationController) {
        let vc = SmilesLocationConfigurator.create(type: .manageAddresses)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
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
        self.navigationController = navigationController
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
