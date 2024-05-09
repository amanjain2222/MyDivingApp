//
//  CreateLogViewController.swift
//  MyDivingApp
//
//  Created by aman on 9/5/2024.
//

import UIKit

class CreateLogViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    


    @IBOutlet weak var LogTitle: UITextField!
    
    
    @IBAction func AddLog(_ sender: Any) {
        
        guard let title = LogTitle.text
        else {
        return
        }
        
        _ = databaseController?.addlog(title: title)
        
        navigationController?.popViewController(animated: true)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
