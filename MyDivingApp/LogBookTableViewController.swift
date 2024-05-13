//
//  LogBookTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/5/2024.
//

import UIKit

class LogBookTableViewController: UITableViewController, DatabaseListener {
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        allLogs = logs
        tableView.reloadData()
    }
    
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    
    var listenerType: ListenerType = .Userlogs
    
    func onAuthenticationChange(ifSucessful: Bool) {
        
    }
    
    
    weak var databaseController: DatabaseProtocol?
    var allLogs:[diveLogs] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        databaseController?.addListener(listener: self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let controller = databaseController else{fatalError()}
        if controller.isSignedIn() {
            return 1
        }
        else{
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let controller = databaseController else{fatalError()}
        if controller.isSignedIn() {
            return allLogs.count
        }else{
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let controller = databaseController else{fatalError()}
        if controller.isSignedIn() == false{
            let warningcell = tableView.dequeueReusableCell(withIdentifier: "Warning", for: indexPath) as! LogBookWarningViewCell
            
            return warningcell
        }
        else{
            let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
            let log = allLogs[indexPath.row]
            var content = logcell.defaultContentConfiguration()
            content.text = log.title
            logcell.contentConfiguration = content
            return logcell
        }

    }
    
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let controller = databaseController else{fatalError()}
        if controller.isSignedIn() == false {
                return 200
            }


           // Use the default size for all other rows.
           return UITableView.automaticDimension
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
