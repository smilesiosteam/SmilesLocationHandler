//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation
import NetworkingLayer
import CoreLocation

class OSMLocationResponse: BaseMainResponse {
    
    // MARK: - Model Keys
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case displayName = "display_name"
        case address = "address"
        case osmType = "osm_type"
        case osmId = "osm_id"
    }
    
    // MARK: - Model Variables
    var latitude: String?
    var longitude: String?
    var displayName: String?
    var address: OSMLocationAddressModel?
    var osmType: String?
    var osmId: Int64?
    
    // MARK: - Model mapping
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        address = try values.decodeIfPresent(OSMLocationAddressModel.self, forKey: .address)
        osmType = try values.decodeIfPresent(String.self, forKey: .osmType)
        osmId = try values.decodeIfPresent(Int64.self, forKey: .osmId)

        try super.init(from: decoder)
    }
    
    // MARK: - Model helper methods
    func getOSMType() -> OSMLocationType? {
        return OSMLocationType(rawValue: self.osmType.asStringOrEmpty())
    }
    
    func getFormattedTitle() -> String {
        let separatedComponents = self.displayName?.components(separatedBy: ", ")
        let formattedTitle = "\(separatedComponents?[safe: 0] ?? ""), \(separatedComponents?[safe: 1] ?? "")"
        
        return formattedTitle
    }
    
    func getLocation() -> CLLocation? {
        return CLLocation(latitude: self.latitude?.toDouble() ?? 0, longitude: self.longitude?.toDouble() ?? 0)
    }
    
}
