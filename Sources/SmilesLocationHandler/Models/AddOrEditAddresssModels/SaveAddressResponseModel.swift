//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import NetworkingLayer

class SaveAddressResponseModel: BaseMainResponse {
    let addressDetail: AddressDetail?
    let addressId: Int?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case addressDetail
        case addressId
        case message
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let details = try? values.decodeIfPresent(AddressDetail.self, forKey: .addressDetail) {
            addressDetail = details
        }
        else {
            addressDetail = nil
        }
        if let addId = try? values.decodeIfPresent(Int.self, forKey: .addressId) {
            addressId = addId
        }
        else {
            addressId = nil
        }
        
        if let mess = try? values.decodeIfPresent(String.self, forKey: .message) {
            message = mess
        }
        else {
            message = nil
        }
        try super.init(from: decoder)
    }
}
