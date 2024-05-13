//
//  DatabaseProtocol.swift
//  FIT3159_LAB03
//
//  Created by aman on 26/3/2024.
//
protocol DatabaseProtocol: AnyObject {
    
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addlog(title: String) -> diveLogs
    func deletelog(log: diveLogs)
    

    
    func addUserLogs(logID: String) async throws -> UserLogs
    func deleteUserLogs(userlog: UserLogs)
    
    func addLogToUserLogs(log: diveLogs, userLog: UserLogs) -> Bool
    func removeLogFromUserLogs(log: diveLogs, userLog: UserLogs)
    
    func login(email: String, password: String)
    func createAccount(email: String, password: String)
    func signOutUser()
    
    func isSignedIn() -> Bool
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
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthenticationChange(ifSucessful: Bool)
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs])
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs])
}
