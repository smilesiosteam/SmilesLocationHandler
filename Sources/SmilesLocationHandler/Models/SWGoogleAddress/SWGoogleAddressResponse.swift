//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import Foundation
import NetworkingLayer

public class SWGoogleAddressResponse : BaseMainResponse {
    
    public var plusCode : SWGooglePlusCode?
    public var results : [SWGoogleResult]?
    public var status : String?
    
    enum CodingKeys: String, CodingKey {
        case plusCode = "plus_code"
        case results = "results"
        case status = "status"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        plusCode = try SWGooglePlusCode(from: decoder)
        results = try values.decodeIfPresent([SWGoogleResult].self, forKey: .results)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        try super.init(from: decoder)
    }
    
}
