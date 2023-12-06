//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

class GetCitiesRequest: SmilesBaseMainRequest {

    var isGuestUser: Bool?

    enum CodingKeys: String, CodingKey {
        case isGuestUser
    }
    
    init(isGuestUser: Bool) {
        super.init()
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(isGuestUser, forKey: .isGuestUser)
    }

}
