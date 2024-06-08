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
    
    func addlog(title: String, divetype: DiveType, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String) -> diveLogs
    func deletelog(log: diveLogs)
    
    func addlogCoredata(title: String, divetype: TypeOFDive, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String)-> Logs
    func deletelog(log: Logs)
    
    func addUserLogs(logID: String, Fname: String, Lname: String) async throws -> UserLogs
    func deleteUserLogs(userlog: UserLogs)
    
    func addLogToUserLogs(log: diveLogs, userLog: UserLogs) -> Bool
    func removeLogFromUserLogs(log: diveLogs)
    
    func login(email: String, password: String)
    func createAccount(email: String, password: String, Fname: String, Lname: String)
    func signOutUser()
    func deleteUserAccount() async throws
    
    func isSignedIn() -> Bool
    var currentUser: FirebaseAuth.User?  {get}
    
    
    var currentUserLogs: UserLogs {get}
    var currentUserDetails: User {get set}
    var currentSender: Sender? { get set }
    
    func findUserByEmail(_ email: String) async throws -> User?
    
    func getUsersFromReferance(Referances: [DocumentReference])async  -> [User]?
    
    func addChannelHelper(name: String, users:[User]) -> Channel?
    func deleteChannel(channel: Channel)
    func changeChannelName(newName: String, channel: Channel)
    
    func addDiveLocation(location: String) -> DiveLocations?
    func deleteLocation(location: DiveLocations)
    func removeUserFromChannel(user: User, channel: Channel)
    
    func isCoredata() -> Bool
}
extension DatabaseProtocol {
    func cleanup() {}
    func addListener(listener: DatabaseListener) {}
    func removeListener(listener: DatabaseListener) {}
    func addlog(title: String, divetype: DiveType, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String) -> diveLogs { return diveLogs() }
    func deletelog(log: diveLogs) {}
    func addlogCoredata(title: String, divetype: TypeOFDive, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String) -> Logs { return Logs() }
    func addDiveLocation(location: String) -> DiveLocations? { return  DiveLocations() }
    func deleteLocation(location: DiveLocations) {}
    func deletelog(log: Logs) {}
    func addUserLogs(logID: String, Fname: String, Lname: String) async throws -> UserLogs { return UserLogs() }
    func deleteUserLogs(userlog: UserLogs) {}
    func addLogToUserLogs(log: diveLogs, userLog: UserLogs) -> Bool { return false }
    func removeLogFromUserLogs(log: diveLogs) {}
    func login(email: String, password: String) {}
    func createAccount(email: String, password: String, Fname: String, Lname: String) {}
    func signOutUser() {}
    func deleteUserAccount() async throws {}
    func isSignedIn() -> Bool { return false }
    var currentUser: FirebaseAuth.User? { return nil }
    var currentUserLogs: UserLogs { return UserLogs() }
    var currentUserDetails: User { get { return User() } set {} }
    var currentSender: Sender? { get { return nil } set {} }
    func findUserByEmail(_ email: String) async throws -> User? { return nil }
    func getUsersFromReferance(Referances: [DocumentReference]) async -> [User]? { return nil }
    func addChannelHelper(name: String, users: [User]) -> Channel? { return nil }
    func deleteChannel(channel: Channel) {}
    func changeChannelName(newName: String, channel: Channel) {}
    func removeUserFromChannel(user: User, channel: Channel) {}
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
    case diveLocations
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthenticationChange(ifSucessful: Bool)
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs])
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs])
    func onChatChange(change: DatabaseChange, userChannels: [Channel])
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations])
    func onLogsChange(change: DatabaseChange, logs: [Logs])
}
