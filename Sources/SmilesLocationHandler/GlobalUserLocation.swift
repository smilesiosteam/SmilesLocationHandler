//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import CoreLocation
import SmilesUtilities

public class GlobalUserLocation {
    
    public var latitude: String?
    public var location: String?
    public var locationId: String?
    public var longitude: String?
    public var fullLocation: String?
    public var locationCoordinate: CLLocation?{
        let latitudeInDouble = Double(latitude.asStringOrEmpty()).asDoubleOrEmpty()
        let longitudeInDouble = Double(longitude.asStringOrEmpty()).asDoubleOrEmpty()
        return CLLocation(latitude: latitudeInDouble, longitude: longitudeInDouble)
    }
    
    
    public static let shared: GlobalUserLocation = {
        let instance = GlobalUserLocation()
        // Setup code
        return instance
    }()
    
    private init() {}
    
}
