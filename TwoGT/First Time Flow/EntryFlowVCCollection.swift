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
        performSegue(withIdentifier: "toBase", sender: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
