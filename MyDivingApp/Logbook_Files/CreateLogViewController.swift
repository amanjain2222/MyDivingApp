//
//  CreateLogViewController.swift
//  MyDivingApp
//
//  Created by aman on 9/5/2024.
//

import UIKit

/*
 This controller is responsible for generating a log and storing it in firebase/coredata appropriately.
 */

class CreateLogViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        if databaseController?.isSignedIn() == false{
            databaseController = appDelegate?.coreDatabaseController
        }
    }
    
    
    
    @IBOutlet weak var LogTitle: UITextField!
    @IBOutlet weak var DiveType: UISegmentedControl!
    @IBOutlet weak var DiveDate: UIDatePicker!
    @IBOutlet weak var DiveLocation: UITextField!
    @IBOutlet weak var Duration: UITextField!
    @IBOutlet weak var weightsUsed: UITextField!
    @IBOutlet weak var additionalComments: UITextField!
    
    
    
    @IBAction func AddLog(_ sender: Any) {
        
        if databaseController?.isCoredata() == false{
            guard let title = LogTitle.text, let diveType = MyDivingApp.DiveType(rawValue:Int(DiveType.selectedSegmentIndex)), let diveLocation = DiveLocation.text, let duration = Duration.text, let weights = weightsUsed.text, let aditionalComments = additionalComments.text
            else {
                displayMessage(title: "Empty Feilds", message: "Make Sure You Fill In All The Feilds")
                return
            }
            
            if title.isEmpty{
                self.displayMessage(title: "Empty title", message: "Please give a title for your dive")
                return
            }
            
            _ = databaseController?.addlog(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: DiveDate.date, duration: duration, weight: weights, comments: aditionalComments)
            
            navigationController?.popViewController(animated: true)
        }else{
            guard let title = LogTitle.text, let diveType = MyDivingApp.TypeOFDive(rawValue: Int32(DiveType.selectedSegmentIndex)), let diveLocation = DiveLocation.text, let duration = Duration.text, let weights = weightsUsed.text, let aditionalComments = additionalComments.text
     
            else {
                return
            }
            
            if title.isEmpty{
                self.displayMessage(title: "Empty title", message: "Please give a title for your dive")
                return
            }
            
            _ = databaseController?.addlogCoredata(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: DiveDate.date, duration: duration, weight: weights, comments: aditionalComments)
            
            navigationController?.popViewController(animated: true)
            
        }
    }
    
}
