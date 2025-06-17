//
//  diveResourcesViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/6/2024.
//

import UIKit
import WebKit

// is a web view of the info and resources page
class diveResourcesViewController: UIViewController {
    
    var webUrl: String = "https://familydoctor.org/scuba-diving-safety/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let resourcesURL = URL(string: webUrl) else{
            displayMessage(title: "invalid url", message: "")
     
            return
        }
 
        let request = URLRequest(url: resourcesURL)
   
        resourcesView.load(request)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBOutlet weak var resourcesView: WKWebView!
    
}
