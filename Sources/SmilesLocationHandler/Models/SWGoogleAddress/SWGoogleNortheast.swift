//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

public class SWGoogleNortheast : Codable {

    public let lat : Float?
    public let lng : Float?


    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(Float.self, forKey: .lat)
        lng = try values.decodeIfPresent(Float.self, forKey: .lng)
//        try super.init(from: decoder)
     }


}
