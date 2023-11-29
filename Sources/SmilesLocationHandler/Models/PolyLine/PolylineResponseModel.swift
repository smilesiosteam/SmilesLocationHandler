//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 29/11/2023.
//

import Foundation
import NetworkingLayer

public class PolylineResponseModel : BaseMainResponse {
    
    public var routes : [Route]?
    public var status : String?
    
    enum CodingKeys: String, CodingKey {
        case routes
        case status
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            routes = try values.decodeIfPresent([Route].self, forKey: .routes)
            status = try values.decodeIfPresent(String.self, forKey: .status)
        } catch {
            print(error)
        }
        
        try super.init(from: decoder)
    }
}

public class Route : Codable {
    
    public var overviewPolyline : OverviewPolyline?
    public var summary : String?
    
    enum CodingKeys: String, CodingKey {
        case overviewPolyline = "overview_polyline"
        case summary
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            overviewPolyline = try values.decodeIfPresent(OverviewPolyline.self, forKey: .overviewPolyline)
            summary = try values.decodeIfPresent(String.self, forKey: .summary)
            
        } catch {
            print(error)
        }
    }
}

public class OverviewPolyline : Codable{
    
    public var points : String?
    
    enum CodingKeys: String, CodingKey {
        case points
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            points = try values.decodeIfPresent(String.self, forKey: .points)
        } catch {
            print(error)
        }
    }
}
