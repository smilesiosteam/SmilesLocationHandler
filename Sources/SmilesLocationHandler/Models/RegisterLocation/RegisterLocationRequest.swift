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
    
    public var userInformation: AppUserInfo? = nil
    public var menuItemType: String? = nil
    public var isGuestUser: Bool? = nil

    enum CodingKeys: String, CodingKey {
        case userInfo
        case menuItemType
        case isGuestUser
    }
    
   public init(userInformation: AppUserInfo? = nil, menuItemType: String? = nil, isGuestUser: Bool = false) {
        super.init()
        self.userInformation = userInformation
        self.menuItemType = menuItemType
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(userInformation, forKey: .userInfo)
        try container.encodeIfPresent(isGuestUser, forKey: .isGuestUser)
    }
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
