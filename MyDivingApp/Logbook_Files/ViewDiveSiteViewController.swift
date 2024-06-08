//
//  ViewDiveSiteViewController.swift
//  MyDivingApp
//
//  Created by aman on 15/5/2024.
//

import UIKit
/*
 This class is responsable for viewing the logs that the users entered by the user.
 */
class ViewDiveSiteViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentLog: diveLogs?  // these are the logs stored in firebase, and will be used to populate this controller if user is signed in
    var currentLogCoredata: Logs? //  these are the logs stored in core data.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // databaseController = firebase controller if the user is signed in and CoreDataController otherwise
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        if databaseController?.isSignedIn() == false{
            databaseController = appDelegate?.coreDatabaseController
        }
        
        if databaseController?.isCoredata() == false{
            diveLocation.text = currentLog?.location ?? "-"
            if let date = currentLog?.date?.formatted(date: .long, time: .shortened){
                diveDate.text = "\(date)"
            }
            diveDuration.text = currentLog?.duration ?? "-"
            diveWeights.text = currentLog?.weights ?? "-"
            diveComments.text = currentLog?.additionalComments ?? "-"
            navigationItem.title = currentLog?.title ?? "Dive details"
        }else{
            
            diveLocation.text = currentLogCoredata?.location ?? "-"
            if let date = currentLog?.date?.formatted(date: .long, time: .shortened){
                diveDate.text = "\(date)"
            }
            diveDuration.text = currentLogCoredata?.duration ?? "-"
            diveWeights.text = currentLogCoredata?.weights ?? "-"
            diveComments.text = currentLogCoredata?.comments ?? "-"
            
            navigationItem.title = currentLogCoredata?.title ?? "Dive details"
            
        }
        
    }
    
    
    @IBOutlet weak var diveLocation: UILabel!
    
    @IBOutlet weak var diveDate: UILabel!
    
    @IBOutlet weak var diveDuration: UILabel!
    
    @IBOutlet weak var diveWeights: UILabel!
    
    @IBOutlet weak var diveComments: UILabel!
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
