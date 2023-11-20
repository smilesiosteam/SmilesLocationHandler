//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWViewport : Codable {

    let northeast : SWLocation?
    let southwest : SWLocation?

    enum CodingKeys: String, CodingKey {
        case northeast
        case southwest
    }
    
    required init(from decoder: Decoder) throws {
        let _ = try decoder.container(keyedBy: CodingKeys.self)
        northeast = try SWLocation(from: decoder)
        southwest = try SWLocation(from: decoder)
     }

}
