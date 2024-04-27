//
//  DiveSiteViewController.swift
//  MyDivingApp
//
//  Created by aman on 25/4/2024.
//

import UIKit

class DiveSiteViewController: UIViewController {
    
    var currentSite: DiveSites?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = currentSite?.name
        
        ocean.text = "Ocean: " + (currentSite?.ocean)!
        ocean.allowsEditingTextAttributes = false
        ocean.borderStyle = .none
        
        region.text = "Region: " + (currentSite?.region)!
        region.allowsEditingTextAttributes = false
        region.borderStyle = .none
        
        longitude.text = "longitude: " + (currentSite?.longitude)!
        longitude.allowsEditingTextAttributes = false
        longitude.borderStyle = .none
        
        latitude.text = "latitude: " + (currentSite?.latitude)!
        latitude.allowsEditingTextAttributes = false
        latitude.borderStyle = .none
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var ocean: UITextField!
    @IBOutlet weak var region: UITextField!
    
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var latitude: UITextField!
    
    /*
     
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
