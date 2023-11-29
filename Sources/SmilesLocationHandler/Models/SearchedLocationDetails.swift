//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

public class SearchedLocationDetails: Codable {
    
    public let addressId: String
    public let title: String
    public let subTitle: String
    public var latitude: Double
    public var longitude: Double
    public var formattedAddress: String?
    
    enum CodingKeys: CodingKey {
        case addressId
        case title
        case subTitle
        case latitude
        case longitude
        case formattedAddress
    }
    
    public init(addressId: String = "", title: String = "", subTitle: String = "", latitude: Double = 0, longitude: Double = 0, formattedAddress: String? = nil) {
        self.addressId = addressId
        self.title = title
        self.subTitle = subTitle
        self.latitude = latitude
        self.longitude = longitude
        self.formattedAddress = formattedAddress
    }
    
}
