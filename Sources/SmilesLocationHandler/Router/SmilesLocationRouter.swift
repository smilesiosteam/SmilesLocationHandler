//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import UIKit

public final class SmilesLocationRouter {
    
    public static let shared = SmilesLocationRouter()
    
    public func presentSetLocationPopUp(on viewController: UIViewController) {
        
        let setLocationPopUp = SmilesLocationConfigurator.create(type: .setLocationPopUp) as! SetLocationPopupViewController
        setLocationPopUp.modalPresentationStyle = .overFullScreen
        viewController.present(setLocationPopUp, animated: true)
        
    }
    
}
