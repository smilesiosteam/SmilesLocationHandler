//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import UIKit
import SmilesUtilities
import SmilesSharedModels

public class RegisterLocationRequest: Codable {
    public var userInfo: AppUserInfo?
    public var menuItemType: String?
    public var isGuestUser: Bool?

    enum CodingKeys: String, CodingKey {
        case userInfo
        case menuItemType
        case isGuestUser
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userInfo = try values.decodeIfPresent(AppUserInfo.self, forKey: .userInfo)
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
