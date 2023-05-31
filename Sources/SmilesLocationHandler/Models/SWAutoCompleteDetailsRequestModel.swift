//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//
import Foundation

public class SWAutoCompleteDetailsRequestModel : NSObject,Codable {
    
    public var placeID : String?
    public var key : String?

    
    
    public override init(){
        super.init()
    }
    enum CodingKeys: String, CodingKey {
        case placeID = "placeid"
        case key = "key"
    
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        placeID = try values.decodeIfPresent(String.self, forKey: .placeID)
        key = try values.decodeIfPresent(String.self, forKey: .key)

    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(placeID,  forKey: .placeID)
        try container.encode(key,  forKey: .key)

        
    }
    
}
