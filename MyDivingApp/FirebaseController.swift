//
//  FirebaseController.swift
//  MyDivingApp
//
//  Created by aman on 26/4/2024.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject {
    
    var authController: Auth
    var currentUser: FirebaseAuth.User?
    var database: Firestore
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
        

    }
    
    
    func login(email: String, password: String){
         Task{
             do{
                 let authResult = try await authController.signIn(withEmail: email, password: password)
                 currentUser = authResult.user

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
                
            }
            catch{
                print(error)
            }
        }
    }
     
}
