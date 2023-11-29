//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

class SaveAddressRequestModel: SmilesBaseMainRequest {
    
    var userInformation: AppUserInfo? = nil
    var address: Address? = nil

    enum CodingKeys: String, CodingKey {
        case userInformation = "userInfo"
        case address
    }

    init(userInfo: AppUserInfo? = nil, address: Address? = nil) {
        super.init()
        
        self.userInformation = userInfo
        self.address = address
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(userInformation, forKey: .userInformation)
    }

   

    func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
