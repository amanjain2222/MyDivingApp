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
    
    
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations]) {
        
    }
    
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
    }
    
    
    // whenever a channel is added/modified this is called to adjus ttableview accordingly
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
        if databaseController?.isSignedIn() == true{
            
            currentuser = databaseController!.currentUserDetails
            
            var filteredChannels: [Channel] = []
            
            
            Task{
                //adding channel users to channel
                for channel in userChannels{
                    if let userChannelUsers = await databaseController?.getUsersFromReferance(Referances: channel.userReferances!){
                        channel.Users = userChannelUsers
                    }
                    for user in channel.Users! {
                        if user.email == (currentuser?.email)!{
                            filteredChannels.append(channel)
                        }
                    }
                }
                
                self.channels = filteredChannels
                currentSender = Sender(senderId: databaseController!.currentUserDetails.UserID! , displayName: databaseController!.currentUserDetails.Fname!)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    
                }
            }
            
            
        }
    }
    
    
    var listenerType: ListenerType = .chat
    
    var indicator = UIActivityIndicatorView()
    
    var channelName: String?
    
    func onAuthenticationChange(ifSucessful: Bool) {
        
        
        if databaseController!.isSignedIn(){
            addChannelButton.isHidden = false
            DispatchQueue.main.async {
                self.tableView.separatorStyle = .singleLine
            }
            
        }else{
            addChannelButton.isHidden = true
            tableView.separatorStyle = .none
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
            indicator.startAnimating()
        }else{
            addChannelButton.isHidden = true
        }
        
        tableView.separatorStyle = .none
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
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
            
            if users!.count < 3{
                for user in users!{
                    if user.Fname != currentuser?.Fname{
                        let oppositeUserName = user.Fname
                        content.text = oppositeUserName
                    }
                }
            }
            else{
                content.text = currentChannel.name
            }
            cell.contentConfiguration = content
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "warninglCell", for: indexPath)
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
    
    
    
    // adding new channels. handling appropriate errors and displaying them to users.
    @IBAction func addChannel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add New Channel", message: "Search Email of the person you want to start a conversation with", preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            
            
            Task{
                guard let requestedUser = try await self.databaseController?.findUserByEmail(alertController.textFields![0].text!) else{
                    self.displayMessage(title: "User Not Found", message: "\(alertController.textFields![0].text!) Not found in database" )
                    return
                }
                
                var usernames: [String] = []
                
                guard let currentUserName = self.currentuser?.Fname, let requestedUserName =  requestedUser.Fname else{
                    return
                }
                
                usernames.append(currentUserName)
                usernames.append(requestedUserName)
                
                self.channelName = usernames.joined(separator: ", ")
                
                var doesExist = false
                for channel in self.channels {
                    if let name = channel.name{
                        if name.lowercased() == self.channelName!.lowercased() {
                            doesExist = true
                        }
                    }
                }
                
                if doesExist{
                    self.displayMessage(title: "Channel already available", message: "")
                }else {
                    
                    _ = self.databaseController?.addChannelHelper(name: self.channelName! , users: [self.currentuser!, requestedUser])
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
            destinationVC.channelName = channel.name
            destinationVC.currentuser = self.currentuser
        }
    }
    
    
    
    
    
    @IBOutlet weak var addChannelButton: UIBarButtonItem!
    
}
