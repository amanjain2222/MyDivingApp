//
//  ChannelsTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import FirebaseFirestore

class ChannelsTableViewController: UITableViewController {
    
    let SEGUE_CHANNEL = "channelSegue"
    let CELL_CHANNEL = "channelCell"
    
    var channels = [Channel]()
    
    var currentSender: Sender?
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        databaseListener = channelsRef?.addSnapshotListener() {
//            (querySnapshot, error) in
//            
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            self.channels.removeAll()
//            
//            querySnapshot?.documents.forEach() {
//                snapshot in
//                
//                let id = snapshot.documentID
//                let name = snapshot["name"] as! String
//                let channel = Channel(id: id, name: name)
//                self.channels.append(channel)
//            }
//            
//            self.tableView.reloadData()
//            
//        }
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    func addChannelHelper(id: String, name: String, channelUsers: [String]){
        let channel = Channel()
//        channel.name = receivers name
        for users in channelUsers{
            channel.channelUsers.append(users)
        }
    
        var data: [String: Any] = [
//                    "id": self.currentSender?.senderId,
            "name": self.currentSender?.displayName ?? "new chat" // I want this to be the name of the receiver instead of sender
            ]
        if let channel = self.channelsRef?.addDocument(data: data){
           
            
        }
//                self.channelsRef?.document().updateData(["channelUsers" : FieldValue.arrayUnion([self.currentSender?.senderId)])
        
    }
    
    @IBAction func addChannel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add New Channel", message: "Search Email of the person you want to start a conversation with", preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            
            let channelName = alertController.textFields![0]
            var doesExist = false
            for channel in self.channels {
                // this logic is not right
                if channel.name!.lowercased() == channelName.text!.lowercased() {
                    for userid in channel.channelUsers{
                        if (userid != self.currentSender?.senderId) /*|| (userid != receiverUSer.uid)*/{
                            doesExist = true
                        }
                    }
                }
            }
            
            if !doesExist {
                
                //self.addChannelHelper(id: <#T##String#>, name: <#T##String#>, channelUsers: <#T##[String]#>)
            }
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        
    }
    

}
