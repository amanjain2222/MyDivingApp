//
//  LoginPageViewController.swift
//  MyDivingApp
//
//  Created by aman on 9/5/2024.
//

import UIKit

class LoginPageViewController: UIViewController, DatabaseListener {
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
        
    }
    
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
    }
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    func onAuthenticationChange(ifSucessful: Bool) {
        if ifSucessful{
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.indicator.stopAnimating()
            }
        }
        
    }
    
    var indicator = UIActivityIndicatorView()
    
    weak var databaseController: DatabaseProtocol?
    
    var listenerType: ListenerType = .authentication


    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
        
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
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        if email == "" || password == "" {
            displayMessage(title: "Empty Feilds", message: "Cannot leave text feilds empty")
            return
        }
        
        indicator.startAnimating()
        databaseController?.login(email: email, password: password)
        
        
    }
    
    
}
