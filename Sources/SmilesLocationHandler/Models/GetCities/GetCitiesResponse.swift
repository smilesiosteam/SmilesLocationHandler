//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import UIKit
import NetworkingLayer

public class GetCitiesResponse: BaseMainResponse {
    
    public var cities: [GetCitiesModel]?

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

public class GetCitiesModel: Codable {
    
    public var cityId: Int?
    public var cityLatitude: Double?
    public var cityLongitude: Double?
    public var cityName: String?
    public var isSelected: Bool = false

    public init(cityId: Int? = nil, cityLatitude: Double? = nil, cityLongitude: Double? = nil, cityName: String? = nil) {
        self.cityId = cityId
        self.cityLatitude = cityLatitude
        self.cityLongitude = cityLongitude
        self.cityName = cityName
    }
    enum CodingKeys: String, CodingKey {
        case cityId
        case cityLatitude
        case cityLongitude
        case cityName
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cityId = try values.decodeIfPresent(Int.self, forKey: .cityId)
        cityLatitude = try values.decodeIfPresent(Double.self, forKey: .cityLatitude)
        cityLongitude = try values.decodeIfPresent(Double.self, forKey: .cityLongitude)
        cityName = try values.decodeIfPresent(String.self, forKey: .cityName)
    }

}
