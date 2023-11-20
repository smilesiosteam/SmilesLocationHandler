//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import Foundation

class SearchedLocationDetails {
    
    let latitude: Double
    let longitude: Double
    let formattedAddress: String?
    
    init(latitude: Double, longitude: Double, formattedAddress: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.formattedAddress = formattedAddress
    }
    
}
