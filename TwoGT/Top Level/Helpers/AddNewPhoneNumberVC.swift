//
//  AddNewPhoneNumberVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/25/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AddNewPhoneNumberVC: UIViewController {
    
    @IBOutlet weak var labelTextField: DesignableTextField!
    @IBOutlet weak var numberTextField: DesignableTextField!
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  CoreDataGod.user.phoneNumbers ?? []
            return phones.isEmpty ? [] : phones.sorted { return $0.title! < $1.title! }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addPhoneNumber() {
        guard let t = labelTextField.text?.lowercased().pure(), let n = numberTextField.text?.pure() else {
            showOkayAlert(title: "", message: "you're trying to save without completing all fields.  bad you.", handler: nil)
            return
        }
        let uid = CoreDataGod.user.uid
        let _ = PhoneNumber.create(title: t, number: n, uid: uid)
        CoreDataGod.save()
        performSegue(withIdentifier: "unwindToYou", sender: nil)
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        if checkValidity() { addPhoneNumber() }
    }
}

extension AddNewPhoneNumberVC {
    private func showReplaceAlert() {
        showOkayOrCancelAlert(title: "Uh Oh", message: "A phone number with this label already exists. Replace??", okayHandler: { (_) in
            self.addPhoneNumber()
        }, cancelHandler: nil)
    }
    
    private func checkValidity() -> Bool {
        for p in phoneNumbers {
            if p.title == labelTextField.text?.pure() {
                showReplaceAlert()
                return false
            }
        }
        
        let outletCollection = [labelTextField, numberTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  You must be trying to pull something.", handler: nil)
                return false
            }
        }
        return true
    }
}
