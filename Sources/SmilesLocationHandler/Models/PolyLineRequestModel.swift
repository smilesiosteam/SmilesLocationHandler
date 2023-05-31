//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation
import SmilesUtilities

public class PolyLineRequestModel: NSObject,Codable {
    public var sourceLat: Double?
    public var sourceLong: Double?
    public var destinationLat: Double?
    public var destinationLong: Double?
    public var apiKey: String?
    public var wayPointsLat: Double?
    public var wayPointsLong: Double?

    public override init(){
         super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case sourceLat
        case sourceLong
        case destinationLat
        case destinationLong
        case apiKey
        case wayPointsLat
        case wayPointsLong
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sourceLat = try values.decodeIfPresent(Double.self, forKey: .sourceLat)
        sourceLong = try values.decodeIfPresent(Double.self, forKey: .sourceLong)
        destinationLat = try values.decodeIfPresent(Double.self, forKey: .destinationLat)
        destinationLong = try values.decodeIfPresent(Double.self, forKey: .destinationLong)
        apiKey = try values.decodeIfPresent(String.self, forKey: .sourceLat)
        wayPointsLat = try values.decodeIfPresent(Double.self, forKey: .wayPointsLat)
        wayPointsLong = try values.decodeIfPresent(Double.self, forKey: .wayPointsLong)
    }
    
    public func encode(to encoder: Encoder) throws
    {
         var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceLat,  forKey: .sourceLat)
        try container.encode(sourceLong,  forKey: .sourceLong)
        try container.encode(destinationLat,  forKey: .destinationLat)
        try container.encode(destinationLong,  forKey: .destinationLong)
        try container.encode(apiKey,  forKey: .apiKey)
        try container.encode(wayPointsLat,  forKey: .wayPointsLat)
        try container.encode(wayPointsLong,  forKey: .wayPointsLong)

    }
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}

