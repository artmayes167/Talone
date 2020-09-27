//
//  AddNewEmailVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/25/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AddNewEmailVC: UIViewController {
    @IBOutlet weak var labelTextField: DesignableTextField!
    @IBOutlet weak var emailTextField: DesignableTextField!
    
    let adder = AddressAdder()
    
    private var emails: [Email] {
        get {
            guard let ems =  AppDelegate.user.emails else { fatalError() }
            var allEms: [Email] = []
            for e in ems {
                allEms.append(e as! Email)
            }
            return allEms.sorted { return $0.name! < $1.name! }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addEmail() {
        let newEmail = Email(context: adder.managedObjectContext)

        newEmail.name = labelTextField.text?.lowercased().pure()
        newEmail.emailString = emailTextField.text?.pure()
        AppDelegate.user.addToEmails(newEmail) // Make sure this works and is necessary

        if adder.saveContext() {
            performSegue(withIdentifier: "unwindToYou", sender: nil)
        }
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        if checkValidity() {
            addEmail()
        }
    }
}

extension AddNewEmailVC {
    private func showReplaceAlert() {
        
        
        showOkayOrCancelAlert(title: "Uh Oh", message: "An address with this label already exists. Replace??", okayHandler: { (_) in
            self.addEmail()
        }, cancelHandler: nil)
    }
    
    private func checkValidity() -> Bool {
        for e in emails {
            if e.name == labelTextField.text?.lowercased().pure() {
                showReplaceAlert()
                return false
            }
        }
        let outletCollection = [labelTextField, emailTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  You must be trying to pull something.", handler: nil)
                return false
            }
        }
        return true
    }
}
