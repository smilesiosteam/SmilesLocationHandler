//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation
import NetworkingLayer

public class SWGooglePlusCode : BaseMainResponse {

    public var compoundCode : String?
    public var globalCode : String?


    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        compoundCode = try values.decodeIfPresent(String.self, forKey: .compoundCode)
        globalCode = try values.decodeIfPresent(String.self, forKey: .globalCode)
        try super.init(from: decoder)
     }
    
}
