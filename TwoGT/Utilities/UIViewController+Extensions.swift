//
//  UIViewController+Extensions.swift
//  UsefulCode
//
//  Created by Mayes, Arthur E. on 2/18/19.
//  Copyright © 2019 Mayes, Arthur E. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    @objc func getKeyElements() -> [String] {
        return []
    }
    
    /// Show an Alert with an "Ok" button.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert.
    ///   - message: The message for the Alert.
    func showOkayAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .cancel, handler: handler)
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    /// Show and Alert with an "Ok" button and a "Cancel" button.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert.
    ///   - message: The message for the Alert.
    ///   - okayHandler: A block to execute when the user taps "Ok".
    func showOkayOrCancelAlert(title: String, message: String, okayHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default, handler: okayHandler)
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    /// Show and Alert with a "Retry" button and a "Cancel" button.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert.
    ///   - message: The message for the Alert.
    ///   - okayHandler: A block to execute when the user taps "Retry".
    func showRetryOrCancelAlert(title: String, message: String, retryHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Retry", style: .default, handler: retryHandler)
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showAdminPasswordAlert(title: String, message: String, okayHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "****"
        }
        let saveAction = UIAlertAction(title: "Enter", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let adminPass = UserDefaults.standard.string(forKey: "admin")
            if firstTextField.text == adminPass {
                okayHandler(alert)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
