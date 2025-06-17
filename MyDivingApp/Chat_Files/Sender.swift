//
//  Sender.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import MessageKit

class Sender: SenderType {
    
    var senderId: String
    var displayName: String
    
    init(senderId: String, displayName: String) {
        
        self.senderId = senderId
        self.displayName = displayName
        
    }


}
