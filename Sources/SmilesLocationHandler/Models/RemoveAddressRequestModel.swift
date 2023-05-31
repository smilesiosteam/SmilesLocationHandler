//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import SmilesUtilities

public class RemoveAddressRequestModel: Codable {
    public var userInfo: UserInfo?
    public var addressId: Int?

    enum CodingKeys: String, CodingKey {
        case userInfo
        case addressId
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userInfo = try values.decodeIfPresent(UserInfo.self, forKey: .userInfo)
        addressId = try values.decodeIfPresent(Int.self, forKey: .addressId)
    }

    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}

public class UserInfo: Codable {
    public var mambaId: String?
    public var locationId: String?

    enum CodingKeys: String, CodingKey {
        case mambaId
        case locationId
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mambaId = try values.decodeIfPresent(String.self, forKey: .mambaId)
        locationId = try values.decodeIfPresent(String.self, forKey: .locationId)
    }
}
