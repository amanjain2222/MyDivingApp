//
//  LoginPageViewController.swift
//  MyDivingApp
//
//  Created by aman on 9/5/2024.
//

import UIKit

class LoginPageViewController: UIViewController, DatabaseListener {
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onAuthenticationChange(ifSucessful: Bool) {
        if ifSucessful{
            DispatchQueue.main.async {
                //                self.performSegue(withIdentifier: "signedIn", sender: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    
    weak var databaseController: DatabaseProtocol?
    
    var listenerType: ListenerType = .authentication


    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }

    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var EmailText: UITextField!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func login(_ sender: Any) {
        
        guard let email = EmailText.text, let password = PasswordText.text
        else{
            return
        }
        databaseController?.login(email: email, password: password)
    }
    
    @IBAction func signup(_ sender: Any) {
        
        guard let email = EmailText.text, let password = PasswordText.text
        else{
            return
        }
        databaseController?.createAccount(email: email, password: password)
    }
    
}
