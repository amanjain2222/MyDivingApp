//
//  FirebaseController.swift
//  MyDivingApp
//
//  Created by aman on 26/4/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {

    var listeners = MulticastDelegate<DatabaseListener>()
    var logsList: [diveLogs]
    var authController: Auth
    var currentUser: FirebaseAuth.User?
    var database: Firestore
    var isUserSignedIn = false
    var userFname: String?
    var userLname: String?
    var userEmail: String?
    var currentUserLogs: UserLogs
    
    var currentUserDetails: User
    
    var currentSender: Sender?
    
    var logRef: CollectionReference?
    
    var userRef: CollectionReference?
    
    var UserlogRef: CollectionReference?
    
    var channelsRef: CollectionReference?
    
    var userChannels: [Channel]
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentUserLogs = UserLogs()
        logsList = [diveLogs]()
        currentUserDetails = User()
        userChannels = [Channel]()
        super.init()
        
                Task {
                    do {
                        try await authController.signOut()
                        isUserSignedIn = false
        
                    }
                    catch {
                        fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
                    }
        
        
                }
       
    }
    
    
    func login(email: String, password: String){
        Task{
            do{
                let authResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authResult.user
                isUserSignedIn = true
                currentUserDetails = try await findUserByEmail(email)!
                self.setUpLogsListener()
                self.setUpChannelsListener()
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat {
                        let wasSuccessful = true
                        listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                        
                    }
                  
                }
    

            }catch{
                print(error)
            }
            
        }
    }
    
    
    func createAccount(email: String, password: String, Fname: String, Lname: String) {
        Task{
            do{
                let authResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authResult.user
                isUserSignedIn = true
                currentUserDetails = try await addUser(email: email, id: currentUser!.uid, Fname: Fname, Lname: Lname)
                _ = try await addUserLogs(logID: currentUser!.uid, Fname: Fname, Lname: Lname)
                self.setUpLogsListener()
                self.setUpChannelsListener()
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat {
                        let wasSuccessful = true
                        listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                    }
                }
                
            }
            catch{
                print(error)
            }
        }
    }
    
    func cleanup() {
        
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
        
//        if listener.listenerType == .heroes || listener.listenerType == .all {
//                    listener.onAllHeroesChange(change: .update, heroes: heroList)
//                }
//        if listener.listenerType == .team || listener.listenerType == .all {
//                    listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes)
//                }
        if listener.listenerType == .authentication || listener.listenerType == .Userlogs {
            if authController.currentUser != nil{
                isUserSignedIn = true
                currentUser = authController.currentUser
                self.setUpLogsListener()
                listener.onAuthenticationChange(ifSucessful: true)
            }
        }

    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func addUser(email: String, id: String, Fname: String, Lname: String) async throws -> User{
        
        userRef = database.collection("Users")
        let user = User()
        user.UserID = id
        user.email = email
        user.Fname = Fname
        user.Lname = Lname
        
        
        let data: [String: Any] = [
                "userEmail": email,
                "userUID": id,
                "Fname": Fname,
                "Lname": Lname
                
            ]

        if let usersRef = try await userRef?.addDocument(data: data) {
            user.id = usersRef.documentID
            }
        
        return user
    }
    
    func addlog(title: String, divetype: DiveType, DiveLocation: String, DiveDate: String) -> diveLogs {
        
        let log = diveLogs()
        log.title = title
        log.type = divetype.rawValue
        log.date = DiveDate
        log.location = DiveLocation
        do {
        if let logsRef = try logRef?.addDocument(from: log) {
            log.id = logsRef.documentID
            }
        } catch {
        print("Failed to serialize hero")
        }
        
        let _ = self.addLogToUserLogs(log: log, userLog: currentUserLogs)
        
        return log
    }
    
    func deletelog(log: diveLogs) {
        if let logID = log.id {
            logRef?.document(logID).delete()
        }
    }
    
    

    
    func addUserLogs(logID: String, Fname: String, Lname: String) async throws -> UserLogs {
        
        UserlogRef = database.collection("UserLogs")
        let log = UserLogs()
        log.UserID = logID
        log.Fname = Fname
        log.Lname = Lname
        var data: [String: Any] = [
                "UserID": logID,
                "Fname": Fname,
                "Lname": Lname
            ]
        if let logsRef = try await UserlogRef?.addDocument(data: data) {
                log.id = logsRef.documentID
            }
        
        return log
    }
    
    func deleteUserLogs(userlog: UserLogs) {
        if let userlogID = userlog.id {
            UserlogRef?.document(userlogID).delete()
        }
    }
    
    func addLogToUserLogs(log: diveLogs, userLog: UserLogs) -> Bool {
        guard let logID = log.id, let userLogID = userLog.id
        else {
            return false
        }
        
        if let newLogRef = logRef?.document(logID) {
            UserlogRef?.document(userLogID).updateData(["logs" : FieldValue.arrayUnion([newLogRef])])
        }
        
        return true
    }
    
    
    func removeLogFromUserLogs(log: diveLogs) {
        if currentUserLogs.logs.contains(log), let logID = log.id, let userLogID = currentUserLogs.id{
            
            if let removedLogRef = logRef?.document(logID) {
                UserlogRef?.document(userLogID).updateData(
                    ["logs": FieldValue.arrayRemove([removedLogRef])]
                )
            }
            deletelog(log: log)
        }
        
    }
    
    func getLogByID(_ id: String) -> diveLogs?{
        for log in logsList {
            if log.id == id {
                return log }
        }
        return nil
    }
    
    
    
    func setUpLogsListener(){
        logRef = database.collection("log")
        
        logRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseLogsSnapshot(snapshot: querySnapshot)
//            if self.UserlogRef == nil {
                self.setupUserlogListener()
//            }
        }
    }
    
    func setupUserlogListener(){
        
        UserlogRef = database.collection("UserLogs")
        UserlogRef?.whereField("UserID", isEqualTo: currentUser!.uid).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first else {
                print("Error fetching teams: \(error!)")
            return
            }
            self.parseUserLogsSnapshot(snapshot: teamSnapshot)
        }
        
    }
    
    func parseLogsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var log: diveLogs
            do {
                log = try change.document.data(as: diveLogs.self)
            } catch {
                fatalError("Unable to decode hero: \(error.localizedDescription)")
            }
            
            if change.type == .added {
                logsList.insert(log, at: Int(change.newIndex))
            }else if change.type == .modified {
                logsList.remove(at: Int(change.oldIndex))
                logsList.insert(log, at: Int(change.newIndex))
            }else if change.type == .removed {
                logsList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.logs || listener.listenerType == ListenerType.all {
                listener.onAllLogsChange(change: .update, logs: logsList)
            }
        }
    }
    
    func parseUserLogsSnapshot(snapshot: QueryDocumentSnapshot){
        currentUserLogs = UserLogs()
        currentUserLogs.UserID = snapshot.data()["UserID"] as? String
        currentUserLogs.Fname = snapshot.data()["Fname"] as? String
        currentUserLogs.Lname = snapshot.data()["Lname"] as? String
        currentUserLogs.id = snapshot.documentID
        
        if let logsReferences = snapshot.data()["logs"] as? [DocumentReference] {
            
            for reference in logsReferences {
                if let log = getLogByID(reference.documentID) {
                    currentUserLogs.logs.append(log)
                }
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.Userlogs ||
                    listener.listenerType == ListenerType.all {
                    listener.onUserLogsChange(change: .update, logs: currentUserLogs.logs)
                }
            }
            
        }
        
        
    }
    
    func setUpChannelsListener(){
        
        channelsRef = database.collection("Channels")
        channelsRef?.addSnapshotListener{
            (querySnapshot,error) in
            
            guard let querySnapshot = querySnapshot else {
                           print("Error fetching teams: \(error!)")
                       return
                       }
            self.parseChannelSnapshot(snapshot: querySnapshot)
        }
    }

    func parseChannelSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var userchannel: Channel
            do{
                userchannel = try change.document.data(as: Channel.self)
            }catch {
                fatalError("Unable to decode channel: \(error.localizedDescription)")
            }
            
            if change.type == .added  && userchannel.channelUsers.contains((currentUser?.email)!){
                            userChannels.insert(userchannel, at: Int(change.newIndex))
                        }else if change.type == .modified && userchannel.channelUsers.contains((currentUser?.email)!){
                            userChannels.remove(at: Int(change.oldIndex))
                            userChannels.insert(userchannel, at: Int(change.newIndex))
                        }else if change.type == .removed && userchannel.channelUsers.contains((currentUser?.email)!){
                            userChannels.remove(at: Int(change.oldIndex))
                        }
            
            
                    }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.chat || listener.listenerType == ListenerType.all {
                listener.onChatChange(change: .update, userChannels: userChannels)
            }
        }

        }
        
    
    

    
    func signOutUser() {
        do{
            try authController.signOut()
            logsList = []
            isUserSignedIn = false
            currentUserLogs = UserLogs()
            currentUser = nil
            userChannels = []
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat{
                    let wasSuccessful = false
                    listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                }
                
                if listener.listenerType == ListenerType.chat{
                    
                    listener.onChatChange(change: .update, userChannels: userChannels)
                }

            }

        }catch{
                print(error)
        }
    }
    
    func isSignedIn() -> Bool {
        return isUserSignedIn
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        
        let userRef = database.collection("Users")
        do {
            let querySnapshot = try await userRef.whereField("userEmail", isEqualTo: email).getDocuments()
            
            guard let userSnapshot = querySnapshot.documents.first else {
                print("No user found with the email: \(email)")
                return nil
            }
            
            return parseUserSnapshot(snapshot: userSnapshot)
        } catch {
            print("Error fetching user: \(error)")
            throw error
        }
    }

    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) -> User? {
        
        let currentUser = User()
        currentUser.UserID = snapshot.data()["userUID"] as? String
        currentUser.Fname = snapshot.data()["Fname"] as? String
        currentUser.Lname = snapshot.data()["Lname"] as? String
        currentUser.email = snapshot.data()["userEmail"] as? String
        
        return currentUser
    }
    
    func addChannelHelper(name: String, channelUsers: [String], channelUserNames: [String]) -> Channel?{

        let channel = Channel()
        channel.name = name
        channel.channelUsers = channelUsers
        channel.channelUsernames = channelUserNames
        
        let data: [String: Any] = [
                    "name": name,
                    "channelUsers": channelUsers,
                    "channelUsernames": channelUserNames
            ]
        channelsRef = database.collection("Channels")
        do {
        if let channelRef = try channelsRef?.addDocument(data: data) {
            channel.id = channelRef.documentID
            }
        } catch {
        print("Failed to serialize hero")
        }
        
        return channel
    }
    

    func deleteChannel(channel: Channel){
        
        if let channelID = channel.id {
            channelsRef?.document(channelID).delete()
        }
        
        
    }
    

}
