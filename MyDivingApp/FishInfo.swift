//
//  FishInfo.swift
//  MyDivingApp
//
//  Created by aman on 16/5/2024.
//

import Foundation

import UIKit


class FishInfo: NSObject, Decodable {
    
    var id: Int?
    var name: String?
    var url: String?
    var imgSrcSet: [String: String]?
    var synonyms: String?
    var species: String?
    var binomial_name: String?
    var conservation_status: String?

    var fishImage: String?
    
    var domain: String?
    var kingdom: String?
    var phylum: String?
    var fishClass: String?
    var superorder: String?
    var order: String?
    var family: String?
    var tribe: String?
    var genus: String?
    var subgenus: String?
    var species2: String?
    
    private enum imageKeys: String, CodingKey {
        
        case smallImage = "1.5x"
        case bigImage = "2x"
    }
    
    private enum FishKeys: String, CodingKey {
        case id
        case name
        case url
        case imgSrcSet = "img_src_set"
        case meta
        
    }
    
    
    private enum scientificKeys: String, CodingKey {
        
        case domain
        case kingdom
        case phylum
        case fishClass = "class"
        case superorder
        case order
        case family
        case tribe
        case genus
        case subgenus
        case species2 = "species"
        
    }
    
    private enum MetaKeys: String, CodingKey {
        case binomial_name
        case conservation_status
        case synonyms
        case species
        case scientificClassification = "scientific_classification"
    }
    
    required init(from decoder: Decoder) throws {
        
        let rootContainer = try decoder.container(keyedBy: FishKeys.self)
        
        id = try? rootContainer.decode(Int.self, forKey: .id)
        name = try? rootContainer.decode(String.self, forKey: .name)
        url = try? rootContainer.decode(String.self, forKey: .url)
        
        
        if let imageContainer = try? rootContainer.nestedContainer(keyedBy: imageKeys.self , forKey: .imgSrcSet){
            fishImage = (try? imageContainer.decode(String.self, forKey: .bigImage)) ?? (try? imageContainer.decode(String.self, forKey: .smallImage))
        }
        
        //imgSrcSet = try rootContainer.decode([String: String].self, forKey: .imgSrcSet)
        
        if let metaContainer = try? rootContainer.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta) {
            
            
            synonyms = try? metaContainer.decode(String.self, forKey: .synonyms)
            species = try? metaContainer.decode(String.self, forKey: .species)
            binomial_name = try? metaContainer.decode(String.self, forKey: .binomial_name)
            conservation_status = try? metaContainer.decode(String.self, forKey: .conservation_status)
            
            
            if let scientificClassificationContainer = try? metaContainer.nestedContainer(keyedBy: scientificKeys.self, forKey: .scientificClassification){
                
                domain = try? scientificClassificationContainer.decode(String.self, forKey: .domain)
                kingdom = try? scientificClassificationContainer.decode(String.self, forKey: .kingdom)
                phylum = try? scientificClassificationContainer.decode(String.self, forKey: .phylum)
                fishClass = try? scientificClassificationContainer.decode(String.self, forKey: .fishClass)
                superorder = try? scientificClassificationContainer.decode(String.self, forKey: .superorder)
                order = try? scientificClassificationContainer.decode(String.self, forKey: .order)
                family = try? scientificClassificationContainer.decode(String.self, forKey: .family)
                tribe = try? scientificClassificationContainer.decode(String.self, forKey: .tribe)
                genus = try? scientificClassificationContainer.decode(String.self, forKey: .genus)
                subgenus = try? scientificClassificationContainer.decode(String.self, forKey: .subgenus)
                species2 = try? scientificClassificationContainer.decode(String.self, forKey: .species2)
            }
            
        }
        

            
        
        
    }
}


