//
//  Extension+UIViewController.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 02/02/2022.
//

import Foundation
import UIKit
import Reachability


extension UIViewController {

    func bindReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: NetworkConnection.shared.reachability)
    }
    
    func unbindReachability() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
 
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .unavailable:
            showAlert(title: "Network Connection Status", message: "Network is unreachable, please note that previewed tasks may not be up to date")
        case .none:
            print("Could not determine")
        default : break
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
