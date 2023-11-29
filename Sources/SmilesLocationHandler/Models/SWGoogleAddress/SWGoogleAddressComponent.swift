//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

public class SWGoogleAddressComponent : Codable {

    public let longName : String?
    public let shortName : String?
    public let types : [String]?


    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types = "types"
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        longName = try values.decodeIfPresent(String.self, forKey: .longName)
        shortName = try values.decodeIfPresent(String.self, forKey: .shortName)
        types = try values.decodeIfPresent([String].self, forKey: .types)
//        try super.init(from: decoder)
     }


}
