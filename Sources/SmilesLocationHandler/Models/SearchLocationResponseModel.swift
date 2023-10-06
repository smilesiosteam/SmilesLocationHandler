//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation
import NetworkingLayer
import SmilesSharedModels

public class SearchLocationResponseModel: BaseMainResponse {
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case title
        case subTitle
        case lat
        case long
        case addressId
        case selectCityName
    }
    
    // MARK: - Model Variables
    
    public var title: String?
    public var subTitle: String?
    public var lat: Double?
    public var long: Double?
    public var addressId: String?
    public var selectCityName: String?
    
    public override init() {
        super.init()
    }
    
    // MARK: - Model mapping
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        subTitle = try values.decodeIfPresent(String.self, forKey: .subTitle)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        long = try values.decodeIfPresent(Double.self, forKey: .long)
        addressId = try values.decodeIfPresent(String.self, forKey: .addressId)
        selectCityName = try values.decodeIfPresent(String.self, forKey: .selectCityName)

        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subTitle, forKey: .subTitle)
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
        try container.encode(addressId, forKey: .addressId)
        try container.encode(selectCityName, forKey: .selectCityName)

    }
}
