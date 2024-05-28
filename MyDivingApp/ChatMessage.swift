//
//  ChatMessage.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import MessageKit

class ChatMessage: MessageType {
    
    var sender: any MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message:String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }
    
}
