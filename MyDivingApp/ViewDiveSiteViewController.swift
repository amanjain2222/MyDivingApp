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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        diveLocation.text = currentLog?.location
        DiveDate.text = currentLog?.date
        
        navigationItem.title = currentLog?.title
        

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
