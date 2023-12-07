//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 06/12/2023.
//

import Foundation
import CoreLocation

protocol ConfirmLocationDelegate: AnyObject {
    
    func locationPicked(location: SearchLocationResponseModel)
    func newAddressAdded(location: CLLocation)
    
}

extension ConfirmLocationDelegate {
    
    func locationPicked(location: SearchLocationResponseModel) {}
    func newAddressAdded(location: CLLocation) {}
    
}
