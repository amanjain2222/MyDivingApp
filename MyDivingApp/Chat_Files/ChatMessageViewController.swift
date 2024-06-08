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

/*
 class responsable to manages Chats between users, making/editing/deleting channels as per user needs
 */

class ChatMessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate,  ChannelNameChangeDelgate {
    
    
    func changedChannelName(_ newName: String) {
        navigationItem.title = newName
        self.channelName = newName
    }
    
    
    var sender: Sender?
    
    var currentChannel: Channel?
    
    var channelName: String?
    
    var messagesList = [ChatMessage]()
    
    var channelRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    var currentSender: SenderType {
        return Sender(senderId: "",displayName: "")
    }
    
    
    var currentuser: User?
    //var oppositeUserName: String?
    
    weak var databaseController: DatabaseProtocol?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        
        if currentChannel != nil {
            let database = Firestore.firestore()
            channelRef = database.collection("Channels").document(currentChannel!.id!).collection("messages")
            
            navigationItem.title = "\(channelName ?? "Anon user")"
        }
        
        tabBarController?.tabBar.isHidden = true
    }
    
    // every time the view appears the chats are displayed based on the time sent
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
    
    
    
    // if you want to add another person in the group chat:
    
    @IBAction func addGroupMember(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add Member To This Chat", message: "Search Email of the person you want to add", preferredStyle: .alert)
        alertController.addTextField()
           
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            
            Task{
                guard let requestedUser = try await self.databaseController?.findUserByEmail(alertController.textFields![0].text!) else{
                    self.displayMessage(title: "User Not Found", message: "\(alertController.textFields![0].text!) Not found in database" )
                    return
                }
                
                
//                if self.currentChannel?.Users!.contains(requestedUser) == true{
//                    self.displayMessage(title: "User already in chat", message: "")
//                    return
//                }
                if let users = self.currentChannel?.Users!{
                    for user in users{
                        if user.UserID == requestedUser.UserID{
                            self.displayMessage(title: "User already in chat", message: "")
                            return
                        }
                    }
                }
                
                var channelUsers:[User] = self.currentChannel!.Users!
                channelUsers.append(requestedUser)
                
                var namesList: [String] = []
                
                for user in channelUsers{
                    if let userName = user.Fname{
                        namesList.append(userName)
                    }
                }
                let channelName = namesList.joined(separator: ", ")
                
                
                if let _ = self.databaseController?.addChannelHelper(name: channelName, users: channelUsers ){
                    self.navigationController?.popViewController(animated: false)
                }
                
            }
            
            
        }
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        
    }
    
    // using delegation to exchange necessary propertiesinformation between view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channelDetails"{
            
            let destination = segue.destination as? channelDetailsViewController
            
            destination?.currentChannelName = channelName
            destination?.currentChannelUsers = currentChannel?.Users
            destination?.currentChannel = currentChannel
            destination?.delegate = self
            
        }
    }
    
    
    
    
}

