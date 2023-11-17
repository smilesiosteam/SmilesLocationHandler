//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation

public class SWGoogleAddressRequestModel : NSObject, Codable {
    
    public var latlng : String?
    public var key : String?
    
    
    public override init(){
        super.init()
    }
    enum CodingKeys: String, CodingKey {
        case latlng = "latlng"
        case key = "key"
    }
    public required init(from decoder: Decoder) throws {
        //        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latlng = try values.decodeIfPresent(String.self, forKey: .latlng)
        key = try values.decodeIfPresent(String.self, forKey: .key)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        //          try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latlng,  forKey: .latlng)
        try container.encode(key,  forKey: .key)
        
    }
    
    
    public func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if latlng != nil{
                 dictionary["latlng"] = latlng
             }
        
        if key != nil{
            dictionary["key"] = key
        }
        return dictionary
    }
    
}
