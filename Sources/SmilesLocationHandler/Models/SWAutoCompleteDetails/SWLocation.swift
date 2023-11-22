//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWLocation : Codable {

    let lat : Double?
    let lng : Double?

    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lng = try values.decodeIfPresent(Double.self, forKey: .lng)
     }

}
