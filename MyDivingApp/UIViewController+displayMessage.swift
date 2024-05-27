//
//  UIViewController+displayMessage.swift
//  MyDivingApp
//
//  Created by aman on 26/5/2024.
//

import Foundation
import UIKit
extension UIViewController {
    
    func displayMessage(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message,
                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
    handler: nil))
    self.present(alertController, animated: true, completion: nil)
    }
    
    
}
