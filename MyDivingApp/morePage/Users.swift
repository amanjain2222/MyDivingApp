//
//  Users.swift
//  MyDivingApp
//
//  Created by Aman Jain on 28/5/2024.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class User: NSObject, Codable {
    
    var Fname: String?
    var Lname: String?
    var email: String?
    @DocumentID var id: String?
    var UserID:String?


}
