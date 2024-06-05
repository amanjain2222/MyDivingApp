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
    
    @IBOutlet weak var DiveDate: UITextField!
    @IBOutlet weak var DiveLocation: UITextField!
    
    
    @IBAction func AddLog(_ sender: Any) {
        
        if databaseController?.isCoredata() == false{
            guard let title = LogTitle.text, let diveType = MyDivingApp.DiveType(rawValue:Int(DiveType.selectedSegmentIndex)), let diveDate = DiveDate.text, let diveLocation = DiveLocation.text
            else {
                return
            }
            
            _ = databaseController?.addlog(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: diveDate)
        }else{
            
            guard let title = LogTitle.text, let diveType = MyDivingApp.TypeOFDive(rawValue: Int32(DiveType.selectedSegmentIndex)), let diveDate = DiveDate.text, let diveLocation = DiveLocation.text
            else {
                return
            }
            
            _ = databaseController?.addlogCoredata(title: title, divetype: diveType, DiveLocation: diveLocation, DiveDate: diveDate)
        }
        
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
