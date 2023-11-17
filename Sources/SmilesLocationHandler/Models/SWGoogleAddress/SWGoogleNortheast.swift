//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

class SWGoogleNortheast : Codable {

    let lat : Float?
    let lng : Float?


    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(Float.self, forKey: .lat)
        lng = try values.decodeIfPresent(Float.self, forKey: .lng)
//        try super.init(from: decoder)
     }


}
