//
//  accountsPageViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/6/2024.
//

import UIKit
// this page is accounts page, only handels teh delete account functionality.

class accountsPageViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
    }
    
    
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "This action can't be redone", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            
            
            Task{
                do{
                    try await self.databaseController?.deleteUserAccount()
                    self.navigationController?.popViewController(animated: true)
                    self.displayMessage(title: "Account Successfully Deleted", message:"")
                }catch{
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                }
            }
            
        }
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    
}
