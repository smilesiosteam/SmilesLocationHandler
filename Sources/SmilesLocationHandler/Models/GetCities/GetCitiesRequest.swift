//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import SmilesUtilities

class GetCitiesRequest: Codable {

    var isGuestUser: Bool?

    enum CodingKeys: String, CodingKey {
        case isGuestUser
    }
    
    init(isGuestUser: Bool) {
        self.isGuestUser = isGuestUser
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isGuestUser = try values.decodeIfPresent(Bool.self, forKey: .isGuestUser)
    }

}
