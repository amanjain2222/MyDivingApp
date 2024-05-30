//
//  DatabaseProtocol.swift
//  FIT3159_LAB03
//
//  Created by aman on 26/3/2024.
//
import Firebase
import FirebaseFirestoreSwift
protocol DatabaseProtocol: AnyObject {
    
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addlog(title: String, divetype: DiveType, DiveLocation: String, DiveDate: String) -> diveLogs
    func deletelog(log: diveLogs)
    
    
    
    func addUserLogs(logID: String, Fname: String, Lname: String) async throws -> UserLogs
    func deleteUserLogs(userlog: UserLogs)
    
    func addLogToUserLogs(log: diveLogs, userLog: UserLogs) -> Bool
    func removeLogFromUserLogs(log: diveLogs)
    
    func login(email: String, password: String)
    func createAccount(email: String, password: String, Fname: String, Lname: String)
    func signOutUser()
    
    func isSignedIn() -> Bool
    var currentUser: FirebaseAuth.User?  {get}
    
    
    var currentUserLogs: UserLogs {get}
    var currentUserDetails: User {get set}
    var currentSender: Sender? { get set }
    
    func findUserByEmail(_ email: String) async throws -> User?
    
    func addChannelHelper(id: String, name: String, channelUsers: [String], channelUserNames: [String]) -> Channel?
    func deleteChannel(channel: Channel)
}


enum DatabaseChange {
    
    case add
    case remove
    case update
    
}
enum ListenerType {

    case all
    case authentication
    case logs
    case Userlogs
    case chat
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthenticationChange(ifSucessful: Bool)
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs])
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs])
    func onChatChange()
}
