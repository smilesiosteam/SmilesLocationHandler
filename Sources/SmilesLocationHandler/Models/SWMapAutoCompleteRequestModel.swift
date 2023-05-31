//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 31/05/2023.
//

import Foundation
import SmilesUtilities

public class SWMapAutoCompleteRequestModel : NSObject,Codable {

    public var intput : String?
    public var key : String?
    public var language : String?
    public var types : String?


    public override init(){
         super.init()
    }
    enum CodingKeys: String, CodingKey {
        case intput = "input"
        case key = "key"
        case language = "language"
        case types = "types"
    }
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        intput = try values.decodeIfPresent(String.self, forKey: .intput)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        types = try values.decodeIfPresent(String.self, forKey: .types)
    }

    public func encode(to encoder: Encoder) throws
    {
         var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(intput,  forKey: .intput)
        try container.encode(key,  forKey: .key)
        if((language) != nil){
             try container.encode(language,  forKey: .language)
        }
        if((types) != nil){
               try container.encode(types,  forKey: .types)
        }
    
    

    }
    
    
    public func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }

}
