//
//  Channel.swift
//  MyDivingApp
//
//  Created by aman on 27/5/2024.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

class Channel: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var userReferances: [DocumentReference]?
    var Users: [User]?

}
