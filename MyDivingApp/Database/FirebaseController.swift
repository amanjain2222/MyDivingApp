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
    func isCoredata() -> Bool {
        return false
    }
    
    
    
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
        
        // Optionally sign out any existing authenticated user at initialization
        
        //                Task {
        //                    do {
        //                        try await authController.signOut()
        //                        isUserSignedIn = false
        //
        //                    }
        //                    catch {
        //                        fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
        //                    }
        //
        //
        //                }
        
    }
    
    
    // Login function to authenticate a user
    func login(email: String, password: String){
        Task{
            do{
                let authResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authResult.user
                isUserSignedIn = true
                currentUserDetails = try await findUserByEmail(email)!
                //setting up listeners for userlogs and channels for this user
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
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat {
                        let wasSuccessful = false
                        listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                        
                    }
                }

            }
  
        }
    }
    
    // Function to create a new user account
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
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat {
                        let wasSuccessful = false
                        listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                    }
                }
            }
        }
    }
    
    // Function to delete user account
    /*
     if the deleteUser account fails it will restore all the data back as orignal and the user is welcome to try again.
     */
    
    func deleteUserAccount() async throws{
        // creating backups incase the delete action fails
        let backupUserDetails = currentUserDetails
        let backuplogs = currentUserLogs
        
        //delete user and user log details in firebase storage
        try await deleteCurrentUser()
        print("Successfully deleted user document from Firestore")
        
        try await deleteUserLogs(userlog: currentUserLogs)
        print("Successfully deleted user logs from Firestore")
        
        do{
            try await authController.currentUser?.delete()
            print("successfully deleted")
            
            //setting everything back to empty as if user is signed out
            self.logsList = []
            self.isUserSignedIn = false
            self.currentUserLogs = UserLogs()
            self.currentUser = nil
            self.userChannels = []
            self.currentUserDetails = User()
            
        
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.Userlogs || listener.listenerType == ListenerType.chat{
                    let wasSuccessful = false
                    listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                }
                
                if listener.listenerType == ListenerType.chat{
                    listener.onChatChange(change: .update, userChannels: self.userChannels)
                }
            }
        }
        catch{
            
            //if it fails all the state is restored here
            currentUserDetails = backupUserDetails
            currentUserLogs = backuplogs
            print("Failed to delete user: \(error.localizedDescription)")
            
        }
    }
    
    
    
    func cleanup() {
        
    }
    
    func addListener(listener: any DatabaseListener)  {
        listeners.addDelegate(listener)
        
        
        if authController.currentUser != nil{
            currentUser = authController.currentUser
            guard let email = currentUser?.email else{
                fatalError()
            }
            isUserSignedIn = true
            Task{
                currentUserDetails = try await findUserByEmail(email)!
                
                
                if listener.listenerType == .authentication || listener.listenerType == .Userlogs {
                    self.setUpLogsListener()
                    listener.onAuthenticationChange(ifSucessful: true)
                }
                
                if listener.listenerType == .chat{
                    listener.onAuthenticationChange(ifSucessful: true)
                    self.setUpChannelsListener()
                    
                    
                }
            }
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // Function to add a user to the database
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
            "Lname": Lname,
            
        ]
        
        if let usersRef = try await userRef?.addDocument(data: data) {
            user.id = usersRef.documentID
        }
        
        return user
    }
    
    
    // Function to add a dive log to the database
    func addlog(title: String, divetype: DiveType, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String) -> diveLogs {
        
        let log = diveLogs()
        log.title = title
        log.type = divetype.rawValue
        log.date = DiveDate
        log.location = DiveLocation
        log.duration = duration
        log.weights = weight
        log.additionalComments = comments
        
        
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
    
    
    
    // Function to add a user log reference
    func addUserLogs(logID: String, Fname: String, Lname: String) async throws -> UserLogs {
        
        UserlogRef = database.collection("UserLogs")
        let log = UserLogs()
        log.UserID = logID
        log.Fname = Fname
        log.Lname = Lname
        let data: [String: Any] = [
            "UserID": logID,
            "Fname": Fname,
            "Lname": Lname
        ]
        if let logsRef = try await UserlogRef?.addDocument(data: data) {
            log.id = logsRef.documentID
        }
        
        return log
    }
    
    //function to add the log referance to teh user they belong to
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
    
    //function to remove a log referance from a user account, later delete=ing that log from database
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
    
    
    // Function to delete the current user from the database
    func deleteCurrentUser() async throws {
        // Check if currentUserDetails.id is not nil and get the userID
        guard let userID = currentUserDetails.id else {
            print("User ID is nil. Cannot delete user.")
            return
        }
        
        // Reference to the user's document
        let userDocument = userRef?.document(userID)
        
        // Delete the user's document
        do {
            try await userDocument?.delete()
            print("User successfully deleted")
        } catch {
            print("Error deleting user: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    // Function to delete user logs from the database
    func deleteUserLogs(userlog: UserLogs)async throws {
        if let userlogID = userlog.id {
            
            do{
                try await UserlogRef?.document(userlogID).delete()
            }
            
            catch{
                print("Error deleting user: \(error.localizedDescription)")
                throw error
            }
            
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
                if let error = error{
                    print("Error fetching UserLogs: \(error)")
                }
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
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.Userlogs ||
                listener.listenerType == ListenerType.all {
                listener.onUserLogsChange(change: .update, logs: currentUserLogs.logs)
            }
        }
        
    }
    
    
    func setUpChannelsListener() {
        channelsRef = database.collection("Channels")
        channelsRef?.addSnapshotListener {
            (querySnapshot,error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Error fetching channels: \(error!)")
                return
            }
            self.parseChannelSnapshot(snapshot: querySnapshot)
        }
    }
    
    
    
    func parseChannelSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            
            
            var userchannel: Channel
            do{
                userchannel = try change.document.data(as: Channel.self)
            }catch {
                fatalError("Unable to decode channel: \(error.localizedDescription)")
            }
            
            
            //                if let userChannelUsers = await self.getUsersFromReferance(Referances: userchannel.userReferances!){
            //                    userchannel.Users = userChannelUsers
            //                }
            
            //                deleteChannel(channel: userchannel)
            
            
            if change.type == .added {
                userChannels.insert(userchannel, at: Int(change.newIndex))
            } else if change.type == .modified {
                userChannels.remove(at: Int(change.oldIndex))
                userChannels.insert(userchannel, at: Int(change.newIndex))
            } else if change.type == .removed {
                userChannels.remove(at: Int(change.oldIndex))
            }
            
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.chat || listener.listenerType == ListenerType.all {
                    listener.onChatChange(change: .update, userChannels: self.userChannels)
                }
            }
            
        }
        
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.chat || listener.listenerType == ListenerType.all {
                listener.onChatChange(change: .update, userChannels: self.userChannels)
            }
        }
        
    }
    
    
    func getUsersFromReferance(Referances: [DocumentReference]) async -> [User]?{
        
        var userChannelUsers: [User] = []
        for reference in Referances {
            let documentSnapshot = try? await userRef?.document(reference.documentID).getDocument()
            
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching Users:")
                return nil
            }
            if let user = self.parseUserSnapshot(snapshot: documentSnapshot){
                userChannelUsers.append(user)
            }
        }
        return userChannelUsers
    }
    
    
    
    
    
    func signOutUser() {
        do{
            try authController.signOut()
            logsList = []
            isUserSignedIn = false
            currentUserLogs = UserLogs()
            currentUser = nil
            userChannels = []
            currentUserDetails = User()
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
    
    
    // function to check if the user is signed in
    func isSignedIn() -> Bool {
        return isUserSignedIn
    }
    
    
    //  find user details given the email of the user
    func findUserByEmail(_ email: String) async throws -> User? {
        userRef = database.collection("Users")
        do {
            let querySnapshot = try await userRef!.whereField("userEmail", isEqualTo: email).getDocuments()
            
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
    
    
    func parseUserSnapshot(snapshot: DocumentSnapshot) -> User? {
        
        let currentUser = User()
        currentUser.UserID = snapshot.data()?["userUID"] as? String
        currentUser.Fname = snapshot.data()?["Fname"] as? String
        currentUser.Lname = snapshot.data()?["Lname"] as? String
        currentUser.email = snapshot.data()?["userEmail"] as? String
        currentUser.id = snapshot.documentID
        return currentUser
    }
    
    //add channel to database
    func addChannelHelper(name: String, users:[User]) -> Channel?{
        let channel = Channel()
        channel.name = name
        channel.userReferances = []
        
        for user in users{
            if let newUserReferance = userRef?.document(user.id!) {
                channel.userReferances?.append(newUserReferance)
            }
        }
        
        let data: [String: Any] = [
            "name": name,
            "userReferances": channel.userReferances!
        ]
        
        channelsRef = database.collection("Channels")
        
        if let channelRef = channelsRef?.addDocument(data: data) {
            channel.id = channelRef.documentID
        }
        
        
        return channel
    }
    
    
    // function to update the name of the channel in database
    func changeChannelName(newName: String, channel: Channel){
        
        channelsRef = database.collection("Channels")
        guard let channelID = channel.id else{
            return
        }
        if let channel = channelsRef?.document(channelID){
            
            channel.updateData(["name" : newName])
            
        }
    }
    
    
    // Function to remove users from a channel if needed
    func removeUserFromChannel(user: User, channel: Channel){
        if let channelID = channel.id, let userID = user.id{
            
            if let removedUserRef = userRef?.document(userID){
                
                channelsRef?.document(channelID).updateData(
                    ["userReferances": FieldValue.arrayRemove([removedUserRef])]
                )
            }
            
        }
        
    }
    
    
    
    func deleteChannel(channel: Channel){
        if let channelID = channel.id {
            channelsRef?.document(channelID).delete()
        }
        
        
    }
    
    func getChannelByID(_ id: String) -> Channel? {
        for channel in userChannels {
            if channel.id == id {
                return channel
            }
        }
        return nil
    }
    
    
}
