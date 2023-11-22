//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 22/11/2023.
//

import Foundation
import NetworkingLayer
import SmilesUtilities

class GetAllAddressesResponse: BaseMainResponse {
    let addressBookLimitReached: Bool?
    let addresses: [Address]?

    enum CodingKeys: String, CodingKey {
        case addressBookLimitReached
        case addresses
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        addressBookLimitReached = try values.decodeIfPresent(Bool.self, forKey: .addressBookLimitReached)
        addresses = try values.decodeIfPresent([Address].self, forKey: .addresses)
        try super.init(from: decoder)
    }
}
