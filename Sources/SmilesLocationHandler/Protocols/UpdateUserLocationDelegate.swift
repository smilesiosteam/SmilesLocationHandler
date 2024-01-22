//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/12/2023.
//

import Foundation

public protocol UpdateUserLocationDelegate: AnyObject {
    
    func userLocationUpdatedSuccessfully()
    func defaultAddressDeleted()
    
}

public extension UpdateUserLocationDelegate {
    func defaultAddressDeleted() {}
}
