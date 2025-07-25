//
//  MoreScreenTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/5/2024.
//

import UIKit

// responsable to view all the other optios available within the app

class MoreScreenTableViewController: UITableViewController, DatabaseListener {
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations]) {
        
    }
    
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
        
    }
    
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
    }
    
    
    var listenerType: ListenerType = .authentication
    
    func onAuthenticationChange(ifSucessful: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    
    let Section_Options = 0
    let Section_Signout = 1
    
    
    weak var databaseController: DatabaseProtocol?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        databaseController?.addListener(listener: self)
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
  
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == Section_Options{
            return 6
        }else {
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == Section_Options {
            if indexPath.row == 0 {
                let profileInfoCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! profileViewTableViewCell
                profileInfoCell.username.text = "\(databaseController?.currentUserDetails.Fname ?? "Anonymous") \( databaseController?.currentUserDetails.Lname ?? "User")"
                profileInfoCell.userEmail.text = databaseController?.currentUser?.email
                
                return profileInfoCell
            }
            else{
                
                let accountCell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
                let settingsCell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
                let equipmentCell = tableView.dequeueReusableCell(withIdentifier: "equipmentCell", for: indexPath)
                let safetyCell = tableView.dequeueReusableCell(withIdentifier: "resourcesCell", for: indexPath)
                let abouttCell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
                
                switch indexPath.row {
                case 1:
                    return accountCell
                case 2:
                    return settingsCell
                case 3:
                    return equipmentCell
                case 4:
                    return safetyCell
                case 5:
                    return abouttCell
                default:
                    fatalError("Unhandled row index")
                }
                
            }
        }
        
        else{
            
            let signoutCell = tableView.dequeueReusableCell(withIdentifier: "signinCell", for: indexPath) as! SignInTableViewCell
            
            if databaseController?.isSignedIn() == false{
                signoutCell.textLable.text = "Sign In"
            }else{
                signoutCell.textLable.text = "Sign Out"
            }
            return signoutCell
            
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section_Signout {
            if databaseController?.isSignedIn() == true{
                databaseController?.signOutUser()
                performSegue(withIdentifier: "toLoginPage", sender: nil)
            }else{
                performSegue(withIdentifier: "toLoginPage", sender: nil)
            }
        }else{
            
            if indexPath.row == 5{
                performSegue(withIdentifier: "aboutPageSegue", sender: nil)
            }else if indexPath.row == 1 && databaseController?.isSignedIn() == true{
                performSegue(withIdentifier: "accountPageSegue", sender: nil)
            }else if indexPath.row == 4{
                performSegue(withIdentifier: "diveSafetySegue", sender: nil)
            }else if indexPath.row == 2{
                performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == Section_Options && indexPath.row == 0{
            return 80
        }
        
        return UITableView.automaticDimension
        
    }
    
}
