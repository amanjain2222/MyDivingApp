//
//  MoreScreenTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/5/2024.
//

import UIKit

class MoreScreenTableViewController: UITableViewController {
    
    let Section_Options = 0
    let Section_Signout = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == Section_Options{
            return 6
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == Section_Options {
            let profileInfoCell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfo", for: indexPath)
            let optionCell = tableView.dequeueReusableCell(withIdentifier: "MoreOptions", for: indexPath)
            if indexPath.row == 0{
                
                profileInfoCell.textLabel?.text = "name"
                profileInfoCell.detailTextLabel?.text = "UserEmail"
                
                return profileInfoCell
            }
            else{
                
                switch indexPath.row {
                case 1:
                    optionCell.textLabel?.text = "Account"
                case 2:
                    optionCell.textLabel?.text = "Settings"
                case 3:
                    optionCell.textLabel?.text = "My Equipment"
                case 4:
                    optionCell.textLabel?.text = "Dive Safety And Resources"
                case 5:
                    optionCell.textLabel?.text = "About"
                default:
                    fatalError("Unhandled row index")
                }
                return optionCell
            }
        }
        
        else{
            let signoutCell = tableView.dequeueReusableCell(withIdentifier: "MoreOptions", for: indexPath)
                        signoutCell.textLabel?.text = "Sign Out"
                        return signoutCell
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == Section_Options{
            return "General"
        }else{
            return " "
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row ==
//
//    }


    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
