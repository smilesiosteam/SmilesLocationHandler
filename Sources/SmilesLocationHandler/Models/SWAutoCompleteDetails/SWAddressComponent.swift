//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWAddressComponent : Codable {

    var longName : String?
    var shortName : String?
    var types : [String]?

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types = "types"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        longName = try values.decodeIfPresent(String.self, forKey: .longName)
        shortName = try values.decodeIfPresent(String.self, forKey: .shortName)
        types = try values.decodeIfPresent([String].self, forKey: .types)
     }

}
