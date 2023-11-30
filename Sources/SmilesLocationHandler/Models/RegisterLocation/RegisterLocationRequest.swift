//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import UIKit
import SmilesUtilities
import SmilesBaseMainRequestManager

public class RegisterLocationRequest: SmilesBaseMainRequest {
    
    public var locationInfo: AppUserInfo?
    public var menuItemType: String?
    public var isGuestUser: Bool?

    enum CodingKeys: String, CodingKey {
        case userInfo
        case menuItemType
        case isGuestUser
    }
    
    public override init() {
        super.init()
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
        try container.encodeIfPresent(self.locationInfo, forKey: .userInfo)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        menuItemType = try values.decodeIfPresent(String.self, forKey: .menuItemType)
        isGuestUser = try values.decodeIfPresent(Bool.self, forKey: .isGuestUser)
    }
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
    
}
