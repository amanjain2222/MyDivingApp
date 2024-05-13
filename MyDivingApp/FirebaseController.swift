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
    
    var currentUserLogs: UserLogs
    
    var logRef: CollectionReference?
    
    var UserlogRef: CollectionReference?
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        currentUserLogs = UserLogs()
        logsList = [diveLogs]()
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
//        
    }
    
    
    func login(email: String, password: String){
        Task{
            do{
                let authResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authResult.user
                isUserSignedIn = true
                self.setUpLogsListener()
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.all {
                        let wasSuccessful = true
                        listener.onAuthenticationChange(ifSucessful: wasSuccessful)
                    }
                }
            }catch{
                print(error)
            }
            
        }
    }
    
    
    func createAccount(email: String, password: String) {
        Task{
            do{
                let authResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authResult.user
                isUserSignedIn = true
                _ = try await addUserLogs(logID: currentUser!.uid)
                self.setUpLogsListener()
                self.listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.authentication || listener.listenerType == ListenerType.all {
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
        if listener.listenerType == .authentication || listener.listenerType == .all {
            if authController.currentUser != nil{
                currentUser = authController.currentUser
                self.setUpLogsListener()
                listener.onAuthenticationChange(ifSucessful: true)
            }
        }

    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func addlog(title: String) -> diveLogs {
        
        let log = diveLogs()
        log.title = title
        
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
    
    

    
    func addUserLogs(logID: String) async throws -> UserLogs {
        UserlogRef = database.collection("UserLogs")
        let log = UserLogs()
        log.UserID = logID
        if let logsRef = try await UserlogRef?.addDocument(data: ["UserID" : logID]) {
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
    
    
    func removeLogFromUserLogs(log: diveLogs, userLog: UserLogs) {
        if userLog.logs.contains(log), let logID = log.id, let userLogID = userLog.id{
            
            if let removedLogRef = logRef?.document(logID) {
                UserlogRef?.document(userLogID).updateData(
                    ["logs": FieldValue.arrayRemove([removedLogRef])]
                )
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
    
    func signOutUser() {
        do{
            try authController.signOut()
            logsList = []
            isUserSignedIn = false
        }catch{
                print(error)
        }
    }
    
    func isSignedIn() -> Bool {
        return isUserSignedIn
    }
    

}
