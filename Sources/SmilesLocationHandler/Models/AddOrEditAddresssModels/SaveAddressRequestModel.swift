//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import SmilesUtilities

public class SaveAddressRequestModel: Codable {
    public var userInfo: SmilesUserInfo?
    public var address: Address?

    enum CodingKeys: String, CodingKey {
        case userInfo
        case address
    }

    init() {}

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userInfo = try values.decodeIfPresent(SmilesUserInfo.self, forKey: .userInfo)
        address = try values.decodeIfPresent(Address.self, forKey: .address)
    }

    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
