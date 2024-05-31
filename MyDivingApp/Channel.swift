//
//  Channel.swift
//  MyDivingApp
//
//  Created by aman on 27/5/2024.
//

import UIKit
import FirebaseFirestoreSwift

class userChannels: NSObject{
    
    var userChannels: [Channel]?
}

class Channel: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var channelUsers: [String] = []
    var channelUsernames: [String] = []
    
//    init(id: String, name: String, channelUsers: [String]?) {
//        self.id = id
//        self.name = name
//        self.channelUsers = channelUsers
//    }



}
