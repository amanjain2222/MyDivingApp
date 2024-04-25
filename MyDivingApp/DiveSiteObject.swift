//
//  DiveSiteObject.swift
//  MyDivingApp
//
//  Created by aman on 24/4/2024.
//

import UIKit

class DiveSiteObject: NSObject, Decodable {
    
    var diveSites: [DiveSites]?
    
    enum CodingKeys: String, CodingKey {
        case diveSites = "data"
        
    }
    
}
