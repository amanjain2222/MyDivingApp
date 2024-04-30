//
//  CurrentLocationViewController.swift
//  MyDivingApp
//
//  Created by aman on 28/4/2024.
//

import UIKit

protocol UpdateLoctionDelegate: AnyObject
{
    func UpdateCurrentLocation(_ Location: String?)
}


class CurrentLocationViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    weak var delegate: UpdateLoctionDelegate?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var CurrentLocation: UITextField!
    
    
    @IBAction func CloseButton(_ sender: Any) {
        delegate?.UpdateCurrentLocation(CurrentLocation.text)
        dismiss(animated: true)
    }
}
