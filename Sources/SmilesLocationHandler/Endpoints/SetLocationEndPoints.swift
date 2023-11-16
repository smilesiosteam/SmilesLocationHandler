//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation

enum SetLocationEndPoints: String {
    case getCities
}

extension SetLocationEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getCities:
            return "location/v1/get-cities"
        }
    }
}
