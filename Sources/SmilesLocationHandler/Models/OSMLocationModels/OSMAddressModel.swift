//
//  File 2.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation
import NetworkingLayer

public class OSMAddressModel: BaseMainResponse {
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
    
    public var residential: String?
    public var state: String?
    public var country: String?
    public var road: String?
    public var suburb: String?
    public var city: String?
    public var neighbourhood: String?
    public var building: String?
    public var stateDistrict: String?
    
    // MARK: - Model mapping
    
    public required init(from decoder: Decoder) throws {
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
