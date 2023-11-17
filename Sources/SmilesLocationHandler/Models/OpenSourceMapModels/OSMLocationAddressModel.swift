//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation
import NetworkingLayer

class OSMLocationAddressModel: BaseMainResponse {
    
    // MARK: - Model Keys
    enum CodingKeys: String, CodingKey {
        case residential
        case state
        case country
        case road
        case suburb
        case city
        case neighbourhood
        case building
        case stateDistrict = "state_district"
    }
    
    // MARK: - Model Variables
    var residential: String?
    var state: String?
    var country: String?
    var road: String?
    var suburb: String?
    var city: String?
    var neighbourhood: String?
    var building: String?
    var stateDistrict: String?
    
    // MARK: - Model mapping
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        residential = try values.decodeIfPresent(String.self, forKey: .residential)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        road = try values.decodeIfPresent(String.self, forKey: .road)
        suburb = try values.decodeIfPresent(String.self, forKey: .suburb)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        neighbourhood = try values.decodeIfPresent(String.self, forKey: .neighbourhood)
        building = try values.decodeIfPresent(String.self, forKey: .building)
        stateDistrict = try values.decodeIfPresent(String.self, forKey: .stateDistrict)

        try super.init(from: decoder)
    }
    
}
