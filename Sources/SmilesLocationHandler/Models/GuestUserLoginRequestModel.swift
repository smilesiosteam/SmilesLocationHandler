//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation
import SmilesUtilities

public class GuestUserLoginRequestModel: Codable {

    public var isGuestUser: Bool?

    enum CodingKeys: String, CodingKey {

        case isGuestUser
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isGuestUser = try values.decodeIfPresent(Bool.self, forKey: .isGuestUser)

    }

    public init() {}

    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
