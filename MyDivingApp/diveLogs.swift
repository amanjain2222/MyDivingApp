//
//  diveLogs.swift
//  MyDivingApp
//
//  Created by aman on 9/5/2024.
//

import Foundation
import FirebaseFirestoreSwift

enum DiveType: Int{
    
    case shore = 0
    case boat = 1
    case pier = 2
    case other = 3
}

enum CodingKeys: String, CodingKey{
    
    case id
    case title
    case type

}
class diveLogs: NSObject, Codable {
    
    @DocumentID var id: String?
    var title: String?
    var type: Int?
    var location: String?
    var date: Date?
    var duration: String?
    var weights: String?
    var additionalComments: String?
    
}

extension diveLogs{
    var diveType: DiveType{
        get{
            return DiveType(rawValue: self.type ?? 3)!
        }
        set{
            self.type = newValue.rawValue
        }
    }
}
