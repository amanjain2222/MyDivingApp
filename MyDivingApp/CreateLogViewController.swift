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
            
            _ = databaseController?.addlog(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: DiveDate.date, duration: duration, weight: weights, comments: aditionalComments)
            
            navigationController?.popViewController(animated: true)
        }else{
            guard let title = LogTitle.text, let diveType = MyDivingApp.TypeOFDive(rawValue: Int32(DiveType.selectedSegmentIndex)), let diveLocation = DiveLocation.text, let duration = Duration.text, let weights = weightsUsed.text, let aditionalComments = additionalComments.text
                    //            guard let title = LogTitle.text, let diveType = MyDivingApp.TypeOFDive(rawValue: Int32(DiveType.selectedSegmentIndex)), let diveDate = DiveDate.text, let diveLocation = DiveLocation.text
            else {
                return
            }
            
            _ = databaseController?.addlogCoredata(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: DiveDate.date, duration: duration, weight: weights, comments: aditionalComments)
            
            navigationController?.popViewController(animated: true)
            
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

}
