//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation
import NetworkingLayer

class SWAutoCompleteDetailsResponseModel : BaseMainResponse {

    var htmlAttributions : [String]?
    var result : SWResult?
    var status : String?


    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case result = "result"
        case status = "status"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        htmlAttributions = try values.decodeIfPresent([String].self, forKey: .htmlAttributions)
        result = try values.decodeIfPresent(SWResult.self, forKey: .result)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        
        try super.init(from: decoder)
     }
    
}
