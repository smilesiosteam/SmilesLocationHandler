//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWPhoto : Codable {

    var height : Int?
    var htmlAttributions : [String]?
    var photoReference : String?
    var width : Int?

    enum CodingKeys: String, CodingKey {
        case height = "height"
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width = "width"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        height = try values.decodeIfPresent(Int.self, forKey: .height)
        htmlAttributions = try values.decodeIfPresent([String].self, forKey: .htmlAttributions)
        photoReference = try values.decodeIfPresent(String.self, forKey: .photoReference)
        width = try values.decodeIfPresent(Int.self, forKey: .width)
     }

}
