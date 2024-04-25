//
//  DiveSites.swift
//  MyDivingApp
//
//  Created by aman on 24/4/2024.
//

import UIKit

class DiveSites: NSObject, Decodable {
    
    var id: String?
    var name: String?
    var region: String?
    var latitude: String?
    var longitude: String?
    var ocean: String?
    var location: String?
    
    
    
    private enum diveSiteKeys: String, CodingKey {
        case id
        case name
        case region
        case latitude = "lat"
        case longitude = "lng"
        case ocean
        case location = "Location"
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let diveSitecontainer = try decoder.container(keyedBy: diveSiteKeys.self)
        
        id = try diveSitecontainer.decode(String.self, forKey: .id)
        name = try diveSitecontainer.decode(String.self, forKey: .name)
        region = try diveSitecontainer.decode(String.self, forKey: .region)
        latitude = try diveSitecontainer.decode(String.self, forKey: .latitude)
        longitude = try diveSitecontainer.decode(String.self, forKey: .longitude)
        ocean = try diveSitecontainer.decode(String.self, forKey: .ocean)
        location = try diveSitecontainer.decode(String.self, forKey: .location)
    }
}

