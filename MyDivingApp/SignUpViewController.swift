//
//  SignUpViewController.swift
//  MyDivingApp
//
//  Created by aman on 15/5/2024.
//

import UIKit

class SignUpViewController: UIViewController, DatabaseListener {
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations]) {
        
    }
    
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
        
    }
    
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
    }
    
    var listenerType: ListenerType = .authentication
    
    func onAuthenticationChange(ifSucessful: Bool) {
        if ifSucessful{
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
    
        
    }
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
        
    }
    
    
    weak var databaseController: DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
    
    
    @IBOutlet weak var Fname: UITextField!
    @IBOutlet weak var Lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        guard let email = email.text, let password = password.text, let Fname = Fname.text,  let Lname = Lname.text
        else{
            
            return
        }
        if email == "" || password == "" || Fname == ""{
            displayMessage(title: "Empty Feilds", message: "Please fill in all the empty feild and rerun the app")
        }
        
        databaseController?.createAccount(email: email, password: password, Fname: Fname, Lname: Lname)
    }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


