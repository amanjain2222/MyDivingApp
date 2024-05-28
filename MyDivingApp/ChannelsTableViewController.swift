//
//  ChannelsTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import FirebaseFirestore
import Firebase

class ChannelsTableViewController: UITableViewController {
    
    let SEGUE_CHANNEL = "channelSegue"
    let CELL_CHANNEL = "channelCell"
    
    var channels = [Channel]()
    
    var currentSender: Sender?
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    var database: Firestore?
    
    weak var databaseController: DatabaseProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        currentSender = Sender(senderId: databaseController!.currentUserDetails.UserID! , displayName: databaseController!.currentUserDetails.Fname!)
        database = Firestore.firestore()
        channelsRef = database!.collection("channels")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseListener = channelsRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            self.channels.removeAll()
            
            querySnapshot?.documents.forEach() {
                snapshot in
                
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let users = snapshot["channelUsers"] as! [String]
                let channel = Channel()
                channel.name = name
                channel.id = id
                channel.channelUsers = users
                if channel.channelUsers.contains(self.currentSender!.senderId){
                    self.channels.append(channel)
                }
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHANNEL, for: indexPath)

        let currentChannel = channels[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.text = currentChannel.name
        cell.contentConfiguration = content

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: SEGUE_CHANNEL, sender: channel)
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
    
    func addChannelHelper(id: String, name: String, channelUsers: [String]){
        let channel = Channel()
        channel.name = name
        
        for users in channelUsers{
            channel.channelUsers.append(users)
        }
    
        var data: [String: Any] = [
                    "id": id,
                    "name": name,
                    "channelUsers": channel.channelUsers
            ]
        self.channelsRef?.addDocument(data: data)
        
    }
    
    
    
    @IBAction func addChannel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add New Channel", message: "Search Email of the person you want to start a conversation with", preferredStyle: .alert)
        alertController.addTextField()
        
        
       
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            
            // set channlName to the receivers name and nott the email entered by the current sender as its done now
            let requestedUser = self.findUserByEmail(alertController.textFields![0].text!)
            let channelName = requestedUser?.Fname
            var doesExist = false
            for channel in self.channels {
                // this logic is not right
                if channel.name!.lowercased() == channelName!.lowercased() {
                    for userid in channel.channelUsers{
                        if (userid != self.currentSender!.senderId) || (userid != requestedUser?.UserID){
                            doesExist = true
                            break
                        }
                    }
                }
            }
            
            if !doesExist {
                
                self.addChannelHelper(id: self.currentSender!.senderId , name: (requestedUser?.Fname)!, channelUsers: [(self.currentSender!.senderId), (requestedUser?.UserID)!] )
            }
            
            
        }
        
 
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        
        
    }
    
    
    func findUserByEmail(_ email: String) -> User? {
        
        let userRef = database!.collection("Users")
        var user: User?
        userRef.whereField("userEmail", isEqualTo: email).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first else {
                print("Error fetching teams: \(error!)")
            return
            }
            user = self.parseUserSnapshot(snapshot: teamSnapshot)
        }
        return user
    }
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) -> User? {
        
        let currentUser = User()
        currentUser.UserID = snapshot.data()["userUID"] as? String
        
        return currentUser
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == SEGUE_CHANNEL{
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChatMessageViewController
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
        }
    }

    
    
    

}
