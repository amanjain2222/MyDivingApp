//
//  DatabaseProtocol.swift
//  MyDivingApp
//
//  Created by aman on 8/5/2024.
//

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
  
    
    func login(email: String, password: String)
    func createAccount(email: String, password: String)
    
    func signOutUser()
}

enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    
    case authentication
}


protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthenticationChange(ifSucessful: Bool)
}
