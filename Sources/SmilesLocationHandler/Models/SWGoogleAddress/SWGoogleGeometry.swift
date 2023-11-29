//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

public class SWGoogleGeometry : Codable {

    public let bounds : SWGoogleBound?
    public let location : SWGoogleNortheast?
    public let locationType : String?
    public let viewport : SWGoogleBound?


    enum CodingKeys: String, CodingKey {
        case bounds
        case location = "location"
        case locationType = "location_type"
        case viewport
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bounds = try SWGoogleBound(from: decoder)
        location = try SWGoogleNortheast(from: decoder)
        locationType = try values.decodeIfPresent(String.self, forKey: .locationType)
        viewport = try SWGoogleBound(from: decoder)
//        try super.init(from: decoder)
     }


}
