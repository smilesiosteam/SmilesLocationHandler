//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import UIKit
import NetworkingLayer

class GetCitiesResponse: BaseMainResponse {
    
    var cities: [GetCitiesModel]?

    enum CodingKeys: String, CodingKey {
        case cities
    }

    override init() { super.init() }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cities = try values.decodeIfPresent([GetCitiesModel].self, forKey: .cities)
        try super.init(from: decoder)
    }
    
}

class GetCitiesModel: Codable {
    
    var cityId: Int?
    var cityLatitude: Double?
    var cityLongitude: Double?
    var cityName: String?
    var isSelected: Bool = false

    enum CodingKeys: String, CodingKey {
        case cityId
        case cityLatitude
        case cityLongitude
        case cityName
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cityId = try values.decodeIfPresent(Int.self, forKey: .cityId)
        cityLatitude = try values.decodeIfPresent(Double.self, forKey: .cityLatitude)
        cityLongitude = try values.decodeIfPresent(Double.self, forKey: .cityLongitude)
        cityName = try values.decodeIfPresent(String.self, forKey: .cityName)
    }

}
