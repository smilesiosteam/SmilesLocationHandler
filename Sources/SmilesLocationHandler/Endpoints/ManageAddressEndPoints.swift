//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import NetworkingLayer

enum ManageAddressEndPoints: String {
    case getLocationsNickName
    case saveAddress
    case getAllAddresses
    case removeAddress
}

extension ManageAddressEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getLocationsNickName:
            return "addressBook/v1/save-update-address"
        case .saveAddress:
            return "addressBook/v1/save-update-address"
        case .getAllAddresses:
            return "addressBook/v1/get-all-addresses"
        case .removeAddress:
            return "addressBook/v1/remove-address"
        }
    }
}
