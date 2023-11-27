//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import NetworkingLayer

enum AddOrEditAddressEndPoints: String {
    case getLocationsNickName
    case saveAddress
    case saveDefaultAddress
    case getAllAddresses
    case removeAddress
}

extension AddOrEditAddressEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getLocationsNickName:
            return EndPoints.saveAddressEndpoint
        case .saveAddress:
            return EndPoints.saveAddressEndpoint
        case .getAllAddresses:
            return EndPoints.getAllAdressesEndpoint
        case .removeAddress:
            return EndPoints.removeAddressEndpoint
        case .saveDefaultAddress:
            return EndPoints.saveDefaultAddressEndpoint
        }
    }
}
