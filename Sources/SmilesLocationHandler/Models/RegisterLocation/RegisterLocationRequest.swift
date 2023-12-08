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
    
    public var locationInfo: AppUserInfo? = nil
    public var menuItemType: String? = nil
    public var isGuestUser: Bool? = nil

    enum CodingKeys: String, CodingKey {
        case userInfo
        case menuItemType
        case isGuestUser
    }
    

   public init(locationInfo: AppUserInfo? = nil, menuItemType: String? = nil, isGuestUser: Bool = false) {
        super.init()
        self.locationInfo = locationInfo
        self.menuItemType = menuItemType
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
        try container.encode(self.locationInfo, forKey: .userInfo)
    }
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
    
}
