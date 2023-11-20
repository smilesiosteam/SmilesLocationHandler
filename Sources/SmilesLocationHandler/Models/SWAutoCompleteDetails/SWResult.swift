//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SWResult : Codable {

    var addressComponents : [SWAddressComponent]?
    var adrAddress : String?
    var formattedAddress : String?
    var geometry : SWGeometry?
    var icon : String?
    var id : String?
    var name : String?
    var photos : [SWPhoto]?
    var placeId : String?
    var plusCode : SWPlusCode?
    var reference : String?
    var scope : String?
    var types : [String]?
    var url : String?
    var utcOffset : Int?

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case adrAddress = "adr_address"
        case formattedAddress = "formatted_address"
        case geometry = "geometry"
        case icon = "icon"
        case id = "id"
        case name = "name"
        case photos = "photos"
        case placeId = "place_id"
        case plusCode
        case reference = "reference"
        case scope = "scope"
        case types = "types"
        case url = "url"
        case utcOffset = "utc_offset"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        addressComponents = try values.decodeIfPresent([SWAddressComponent].self, forKey: .addressComponents)
        adrAddress = try values.decodeIfPresent(String.self, forKey: .adrAddress)
        formattedAddress = try values.decodeIfPresent(String.self, forKey: .formattedAddress)
        geometry = try values.decodeIfPresent(SWGeometry.self, forKey: .geometry)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        photos = try values.decodeIfPresent([SWPhoto].self, forKey: .photos)
        placeId = try values.decodeIfPresent(String.self, forKey: .placeId)
        plusCode = try SWPlusCode(from: decoder)
        reference = try values.decodeIfPresent(String.self, forKey: .reference)
        scope = try values.decodeIfPresent(String.self, forKey: .scope)
        types = try values.decodeIfPresent([String].self, forKey: .types)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        utcOffset = try values.decodeIfPresent(Int.self, forKey: .utcOffset)
     }

}
