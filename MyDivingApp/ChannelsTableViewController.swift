//
//  ChannelsTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/5/2024.
//

import UIKit
import FirebaseFirestore
import Firebase

class ChannelsTableViewController: UITableViewController, DatabaseListener {
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {

        currentuser = databaseController!.currentUserDetails
        self.channels = userChannels
        currentSender = Sender(senderId: databaseController!.currentUserDetails.UserID! , displayName: databaseController!.currentUserDetails.Fname!)
        self.tableView.reloadData()

    }
    
    
    var listenerType: ListenerType = .chat
    
    
    func onAuthenticationChange(ifSucessful: Bool) {
        
        if databaseController!.isSignedIn(){
            addChannelButton.isHidden = false
        }else{
            addChannelButton.isHidden = true
        }
    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    
    let SEGUE_CHANNEL = "channelSegue"
    let CELL_CHANNEL = "channelCell"
    
    var channels = [Channel]()
    
    var currentSender: Sender?
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    weak var databaseController: DatabaseProtocol?
    
    var currentuser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let database = Firestore.firestore()
        channelsRef = database.collection("Channels")
        databaseController?.addListener(listener: self)
        
        if databaseController!.isSignedIn(){
            addChannelButton.isHidden = false
        }else{
            addChannelButton.isHidden = true
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
     
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
        if databaseController!.isSignedIn(){
            return channels.count
        }else{
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if databaseController!.isSignedIn(){
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHANNEL, for: indexPath)
            let currentChannel = channels[indexPath.row]
            var content = cell.defaultContentConfiguration()
            
            
            let users = currentChannel.Users
            for user in users!{
                if user.Fname != currentuser?.Fname{
                    let oppositeUserName = user.Fname
                    content.text = oppositeUserName
                }
            }
            
//            if let userChannelUsers = databaseController?.getUsersFromReferance(Referances: currentChannel.userReferances!){
//                for user in userChannelUsers{
//                    if user.Fname != currentuser?.Fname{
//                        let oppositeUserName = user.Fname
//                        content.text = oppositeUserName
//                    }
//                }
//            }
            cell.contentConfiguration = content
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "warninglCell", for: indexPath)
//            var content = cell.defaultContentConfiguration()
//            content.text = "Sign in before using chat"
//            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let controller = databaseController else{fatalError()}
        if controller.isSignedIn() == false {
                return 500
            }


           // Use the default size for all other rows.
           return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: SEGUE_CHANNEL, sender: channel)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if databaseController?.isSignedIn() == false {
            return false
        }
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.databaseController?.deleteChannel(channel: channels[indexPath.row])
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if databaseController?.isSignedIn() == false{
            return nil
        }
        return indexPath
    }
    

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
    

    
    
    
    @IBAction func addChannel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add New Channel", message: "Search Email of the person you want to start a conversation with", preferredStyle: .alert)
        alertController.addTextField()
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            
            
            Task{
                let requestedUser = try await self.databaseController?.findUserByEmail(alertController.textFields![0].text!)
                let channelName = requestedUser?.Fname
                
                var doesExist = false
                for channel in self.channels {
                    if channel.name!.lowercased() == channelName!.lowercased() {
                        doesExist = true
                    }
                }
                
                
                if !doesExist {
                    
                    _ = self.databaseController?.addChannelHelper(name: (requestedUser?.Fname)!, users: [self.currentuser!, requestedUser!])
                }
            }
            
            
        }
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == SEGUE_CHANNEL{
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChatMessageViewController
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
            let users = channel.Users
            for user in users! {
                if user.Fname != currentuser?.Fname{
                    let oppositeUserName = user.Fname
                    destinationVC.oppositeUserName = oppositeUserName
                }
            }
            destinationVC.currentuser = self.currentuser
        }
    }


    
    
    
    @IBOutlet weak var addChannelButton: UIBarButtonItem!
    
}
