//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import SmilesUtilities
import SmilesBaseMainRequestManager

public class RemoveAddressRequestModel: SmilesBaseMainRequest {
    public var userInformation: SmilesUserInfo? = nil
    public var addressId: String? = nil

    enum CodingKeys: String, CodingKey {
        case userInformation = "userInfo"
        case addressId
    }

    public init(userInformation: SmilesUserInfo? = nil, addressId: String? = nil) {
        super.init()
        self.userInformation = userInformation
        self.addressId = addressId
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userInformation = try values.decodeIfPresent(SmilesUserInfo.self, forKey: .userInformation)
        addressId = try values.decodeIfPresent(String.self, forKey: .addressId)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(addressId, forKey: .addressId)
        try container.encodeIfPresent(userInformation, forKey: .userInformation)
    }

    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}

public class SmilesUserInfo: Codable {
    public var mambaId: String? = nil
    public var locationId: String? = nil

    enum CodingKeys: String, CodingKey {
        case mambaId
        case locationId
    }

    public init(mambaId: String? = nil, locationId: String? = nil) {
        
        self.mambaId = mambaId
        self.locationId = locationId
    }
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    public  func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(mambaId, forKey: .mambaId)
        try container.encodeIfPresent(locationId, forKey: .locationId)
    }
    
}
