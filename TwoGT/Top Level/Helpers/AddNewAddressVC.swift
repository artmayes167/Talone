//
//  AddNewAddressVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/25/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class AddNewAddressVC: UIViewController {
    
     // MARK: - IBOutlets
    
    @IBOutlet weak var labelTextField: DesignableTextField!
    @IBOutlet weak var street1TextField: DesignableTextField!
    @IBOutlet weak var street2TextField: DesignableTextField!
    @IBOutlet weak var cityStateTextField: DesignableTextField!
    @IBOutlet weak var zipTextField: DesignableTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var addresses: [Address] {
        get {
            let adds =  CoreDataGod.user.addresses ?? []
            return adds.isEmpty ? [] : adds.sorted { return $0.title < $1.title }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        if checkValidity() { addAddress() }
    }
    
    func addAddress() {
        guard let t = labelTextField.text?.lowercased().pure(), let s1 = street1TextField.text?.pure(), let zip = zipTextField.text?.pure() else {
            showOkayAlert(title: "nope".taloneCased(), message: "there is not enough information here to qualify as a real address.  you can literally type whatever you want, and other people will see it, if you send it to them. your choice, obviously. but if you want to save it, you're going to have to do better than this.".taloneCased(), handler: nil)
            return
        }
        
        let s2 = street2TextField.text?.pure()
        if let loc = savedLocation {
            Address.create(title: t, street1: s1, street2: s2, city: loc.city, zip: zip, state: loc.state, country: loc.country)
        } else { fatalError() }
        
        try? CoreDataGod.managedContext.save()
        performSegue(withIdentifier: "unwindToYou", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCityState" {
            view.endEditing(true)
            guard let vc = segue.destination as? CityStateSearchVC else { fatalError() }
            vc.unwindSegueIdentifier = "unwindToNewAddress"
        }
    }
    
    var savedLocation: SearchLocation?
    
    @IBAction func unwindToAddNewAddress( _ segue: UIStoryboardSegue) {
        if let vc = segue.source as? CityStateSearchVC {
            guard let loc = vc.locationForSave else { fatalError() }
            savedLocation = loc
            cityStateTextField.text = loc.displayName()
            try? CoreDataGod.managedContext.save()
        }
    }
    
    // MARK: - Keyboard Notifications
    var initialContentInset: UIEdgeInsets = UIEdgeInsets()
   @objc func keyboardWillShow(notification: NSNotification) {
       let userInfo = notification.userInfo!
       var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
       keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        if initialContentInset == UIEdgeInsets() {
            initialContentInset = self.scrollView.contentInset
        }
       
        scrollView.contentInset = contentInset
   }

   @objc func keyboardWillHide(notification: NSNotification) {
       scrollView.contentInset = initialContentInset
   }
}

extension AddNewAddressVC {
    private func showReplaceAlert() {
        showOkayOrCancelAlert(title: "Uh Oh", message: "An address with this label already exists. Replace?".taloneCased(), okayHandler: { (_) in
            self.addAddress()
        }, cancelHandler: nil)
    }
    
    private func checkValidity() -> Bool {
        for a in addresses {
            if a.title == labelTextField.text?.lowercased().pure() {
                showReplaceAlert()
                return false
            }
        }
        
        
        let outletCollection = [labelTextField, street1TextField, cityStateTextField, zipTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  So, everything except Address Line 2 needs to be filled in with something.  It doesn't have to be a real address, I suppose.  But we decided it shouldn't be empty.".taloneCased(), handler: nil)
                return false
            }
        }
        return true
    }
}

 // MARK: - UITextFieldDelegate
extension AddNewAddressVC {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityStateTextField {
            textField.resignFirstResponder()
            performSegue(withIdentifier: "toCityState", sender: nil)
        }
    }
}
