//
//  Alert.swift
//  testMapRoute
//
//  Created by admin on 30.07.2021.
//

import UIKit
extension UIViewController {
    func alertAddAdress(title: String, placeholde: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
            let textField = alertController.textFields?.first
            guard let text = textField?.text else { return }
            completionHandler(text)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            print("AlertCancel")
        }
        alertController.addTextField { (textfield) in
            textfield.placeholder = placeholde
        }
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertOk)
        present(alertController, animated: true , completion: nil)
    }
}
