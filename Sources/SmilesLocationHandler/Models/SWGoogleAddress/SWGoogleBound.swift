//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

class SWGoogleBound : Codable {

    let northeast : SWGoogleNortheast?
    let southwest : SWGoogleNortheast?


    enum CodingKeys: String, CodingKey {
        case northeast
        case southwest
    }
    required init(from decoder: Decoder) throws {
        let _ = try decoder.container(keyedBy: CodingKeys.self)
        northeast = try SWGoogleNortheast(from: decoder)
        southwest = try SWGoogleNortheast(from: decoder)
//        try super.init(from: decoder)
     }


}
