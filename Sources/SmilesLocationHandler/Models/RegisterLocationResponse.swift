//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import UIKit
import SmilesUtilities
import SmilesBaseMainRequestManager
import NetworkingLayer
import SmilesSharedModels

public class RegisterLocationResponse: BaseMainResponse {
    public var userInfo: AppUserInfo?

    enum CodingKeys: String, CodingKey {
        case userInfo
    }
    
    public override init() { super.init() }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userInfo = try values.decodeIfPresent(AppUserInfo.self, forKey: .userInfo)
        try super.init(from: decoder)
    }
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
