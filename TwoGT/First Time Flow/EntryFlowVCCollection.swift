//
//  EntryFlowVCCollection.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class EnterEmailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func submitEmail(_ sender: Any) {
        performSegue(withIdentifier: "toVerification", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class EnterVerificationVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    
   
    @IBAction func submitVerification(_ sender: Any) {
        performSegue(withIdentifier: "toHandle", sender: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

class EnterHandleVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func submitHandle(_ sender: Any) {
        // completion
        showOkayAlert(title: "Welcome, \(textField.text!)", message: String(format: "As an Elite Tester, you can provide Feedback from (almost) any page, by swiping left ( <- ). \n\nReturn by swiping right, or submitting feedback. \n\n Welcome to the first step in a new way to link people in communities.")) { _ in
            self.performSegue(withIdentifier: "toBase", sender: nil)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
