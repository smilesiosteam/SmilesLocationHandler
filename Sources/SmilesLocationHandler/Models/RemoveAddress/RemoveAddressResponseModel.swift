//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation
import NetworkingLayer

public class RemoveAddressResponseModel: BaseMainResponse {
    public var status: Int?
    public var message: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let addId = try? values.decodeIfPresent(Int.self, forKey: .status) {
            status = addId
        }
        else {
            status = nil
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
