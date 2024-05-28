//
//  ChatMessageViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore


class ChatMessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {

    var sender: Sender?
    
    var currentChannel: Channel?
    
    var messagesList = [ChatMessage]()
    
    var channelRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    var currentSender: SenderType {
        return Sender(senderId: "",displayName: "")
    }
    
    let formatter: DateFormatter = {
    let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        
        if currentChannel != nil {
        let database = Firestore.firestore()
            channelRef = database.collection("channels").document(currentChannel!.id!).collection("messages")
            navigationItem.title = "\(currentChannel!.name)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseListener = channelRef?.order(by: "time").addSnapshotListener() {
            (querySnapshot, error) in
            
            if let error = error { print(error)
                return
            }
            
            querySnapshot?.documentChanges.forEach() {
                change in
                if change.type == .added {
                    let snapshot = change.document
                    let id = snapshot.documentID
                    let senderId = snapshot["senderId"] as! String
                    let senderName = snapshot["senderName"] as! String
                    let messageText = snapshot["text"] as! String
                    let sentTimestamp = snapshot["time"] as! Timestamp
                    let sentDate = sentTimestamp.dateValue()
                    let sender = Sender(senderId: senderId, displayName: senderName)
                    let message = ChatMessage(sender: sender, messageId: id,sentDate: sentDate, message: messageText)
                    self.messagesList.append(message)
                    self.messagesCollectionView.insertSections([self.messagesList.count-1])
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesList.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes:[NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty {
            return
        }
        channelRef?.addDocument(data: [
            "senderId" : sender!.senderId,
            "senderName" : sender!.displayName,
            "text" : text,
            "time" : Timestamp(date: Date.init())
        ])
        
        inputBar.inputTextView.text = ""
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)  -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

}

