//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWGeometry : Codable {

    var location : SWLocation?
    var viewport : SWViewport?
    
    enum CodingKeys: String, CodingKey {
        case location = "location"
        case viewport
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        location =  try values.decodeIfPresent(SWLocation.self, forKey: .location)
        viewport = try SWViewport(from: decoder)
     }

}
