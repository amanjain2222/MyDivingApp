//
//  webViewController.swift
//  MyDivingApp
//
//  Created by aman on 7/6/2024.
//

import UIKit
import WebKit

class webViewController: UIViewController {

 
    @IBOutlet weak var webView: WKWebView!
    var webUrl: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let FishInfoUrl = URL(string: webUrl ?? "invalid" ) else{
            displayMessage(title: "invalid url", message: "")
     
            return
        }
 
        let request = URLRequest(url: FishInfoUrl)
   
        
        
        webView.load(request)
        

        // Do any additional setup after loading the view.
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
