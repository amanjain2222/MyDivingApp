//
//  Channel.swift
//  MyDivingApp
//
//  Created by aman on 27/5/2024.
//

import UIKit
class userChannels: NSObject{
    
    var userChannels: [Channel]?
}

class Channel: NSObject {
    
    var id: String?
    var name: String?
    var channelUsers: [String] = []
    
//    init(id: String, name: String, channelUsers: [String]?) {
//        self.id = id
//        self.name = name
//        self.channelUsers = channelUsers
//    }



}
