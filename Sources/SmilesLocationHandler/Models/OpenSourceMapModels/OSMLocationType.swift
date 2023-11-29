//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import Foundation

public enum OSMLocationType: String {
    case node = "node"
    case way = "way"
    case relation = "relation"
    
    var urlParameter: String {
        switch self {
        case .node:
            return "N"
        
        case .way:
            return "W"
            
        case .relation:
            return "R"
        }
    }
}
