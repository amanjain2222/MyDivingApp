//
//  ViewDiveSiteViewController.swift
//  MyDivingApp
//
//  Created by aman on 15/5/2024.
//

import UIKit

class ViewDiveSiteViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentLog: diveLogs?
    var currentLogCoredata: Logs?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        if databaseController?.isSignedIn() == false{
            databaseController = appDelegate?.coreDatabaseController
        }
        
        if databaseController?.isCoredata() == false{
            diveLocation.text = currentLog?.location
            DiveDate.text = currentLog?.date
            
            navigationItem.title = currentLog?.title
        }else{
            diveLocation.text = currentLogCoredata?.location
            DiveDate.text = currentLogCoredata?.date
            
            navigationItem.title = currentLogCoredata?.title
            
        }
        

        // Do any additional setup after loading the view.
    }
    

    

    @IBOutlet weak var diveLocation: UILabel!
    @IBOutlet weak var DiveDate: UILabel!
    
    @IBOutlet weak var diveType: UILabel!
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
