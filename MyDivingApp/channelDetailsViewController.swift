//
//  channelDetailsViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/6/2024.
//

import UIKit

protocol ChannelNameChangeDelgate: AnyObject
{
    func changedChannelName(_ newName: String)
}


class channelDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentChannelUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelUser", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        var username: String?
        if let currentUsers = currentChannelUsers{
            username = currentUsers[indexPath.row].Fname ?? "Deleted user"
        }
        
        content.text = username
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var currnetUser: User
        if editingStyle == .delete {
            if var currentUsers = currentChannelUsers{
                currnetUser = currentUsers[indexPath.row]
                databaseController?.removeUserFromChannel(user: currnetUser, channel: currentChannel!)
                currentChannelUsers!.remove(at: indexPath.row)
                tableView.reloadData()
                
            }
            
            
            
            
        }
    }
    
    weak var databaseController: DatabaseProtocol?
    
    weak var delegate: ChannelNameChangeDelgate?
    
    var currentChannelName: String?
    var currentChannelUsers: [User]?
    var currentChannel: Channel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        ChannelUsers.delegate = self
        ChannelUsers.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        channelName.text = currentChannelName
        
        if currentChannelUsers!.count < 3{
            editNameButton.isHidden = true
        }else{
            editNameButton.isHidden = false
        }
    }

    @IBOutlet weak var channelName: UILabel!
    
    @IBOutlet weak var ChannelUsers: UITableView!
    
    
    @IBAction func editChannelName(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Enter Channel Name", message: "", preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let newName = alertController.textFields![0].text, newName != "" else{
                return
            }
            
            guard let channel = self.currentChannel else{
                return
            }
            self.databaseController?.changeChannelName(newName: newName, channel: channel)
            self.delegate?.changedChannelName(newName)
            
            self.dismiss(animated: true)
            }
            
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        
        
        
    }
    
    
    @IBOutlet weak var editNameButton: UIButton!
    
}
