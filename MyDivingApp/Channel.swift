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
    var users: [User]?
//    var channelUsers: [String] = []
//    var channelUsernames: [String] = []
    
//    init(id: String, name: String, channelUsers: [String]?) {
//        self.id = id
//        self.name = name
//        self.channelUsers = channelUsers
//    }



}
