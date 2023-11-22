//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 21/11/2023.
//

import Foundation
import SmilesUtilities

struct AddressDetail : Codable {
    let nicknames : [Nicknames]?

    enum CodingKeys: String, CodingKey {

        case nicknames = "nicknames"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let nicknames = try? values.decodeIfPresent([Nicknames].self, forKey: .nicknames){
            self.nicknames = nicknames
        }
        else{
            self.nicknames = nil

        }
    }

}
