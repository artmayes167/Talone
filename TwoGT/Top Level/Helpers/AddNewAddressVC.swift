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
            return adds.isEmpty ? [] : adds.sorted { return $0.title! < $1.title! }
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
        guard let t = labelTextField.text?.pure(), let s1 = street1TextField.text?.pure(), let zip = zipTextField.text?.pure() else {
            showOkayAlert(title: "nope".taloneCased(), message: "there is not enough information here to qualify as a real address.  you can literally type whatever you want, and other people will see it, if you send it to them. your choice, obviously. but if you want to save it, you're going to have to do better than this.".taloneCased(), handler: nil)
            return
        }
        
        let s2 = street2TextField.text?.pure()
        if let loc = savedLocation {
            Address.create(title: t, street1: s1, street2: s2, city: loc.city, zip: zip, state: loc.state, country: loc.country)
        } else { fatalError() }
        
        performSegue(withIdentifier: "unwindToYou", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCityState" {
            segue.destination.presentationController?.delegate = self
            guard let vc = segue.destination as? CityStateSearchVC else { fatalError() }
            vc.unwindSegueIdentifier = .addNewAddress
        }
    }
    
    var savedLocation: CityStateSearchVC.Loc?
    
    @IBAction func unwindToAddNewAddress( _ segue: UIStoryboardSegue) {
        if let vc = segue.source as? CityStateSearchVC {
            savedLocation = vc.loc
            cityStateTextField.text = savedLocation!.displayName()
        }
    }
    
    // MARK: - Keyboard Notifications
    var initialContentInset: UIEdgeInsets = UIEdgeInsets()
   @objc func keyboardWillShow(notification: NSNotification) {
    if let n = notification.userInfo?.description { print(n) }
    if initialContentInset == UIEdgeInsets() {
        initialContentInset = self.scrollView.contentInset
    }
       let userInfo = notification.userInfo!
       var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
       keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 50
        
       
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
            if a.title == labelTextField.text?.pure() {
                showReplaceAlert()
                return false
            }
        }
        
        
        let outletCollection = [labelTextField, street1TextField, cityStateTextField, zipTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  So, everything except Address Line 2 needs to be filled in with something.  It doesn't have to be a real address, I suppose.  But we decided it shouldn't be empty.", handler: nil)
                return false
            }
        }
        return true
    }
}

 // MARK: - UITextFieldDelegate
extension AddNewAddressVC {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        var theTextFieldTruth = 0
        if textField == cityStateTextField {
            let tfs: [UITextField] = [labelTextField, street1TextField, street2TextField, cityStateTextField, zipTextField]
            for tf in tfs {
                if tf.endEditing(true) {
                    theTextFieldTruth += 1
                    print("ended editing")
                } else {
                    print("refused to end editing")
                }
            }
            if theTextFieldTruth == 5 {
                performSegue(withIdentifier: "toCityState", sender: nil)
            } else {
                showOkayAlert(title: "", message: "this is a desperate attempt to dismiss the keyboard.", handler: nil)
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == cityStateTextField {
            var theTextFieldTruth = 0
            let tfs: [UITextField] = [labelTextField, street1TextField, street2TextField, cityStateTextField, zipTextField]
            for tf in tfs {
                DispatchQueue.main.async {
                    if tf.endEditing(true) {
                        theTextFieldTruth += 1
                        print("ended editing")
                    } else {
                        print("refused to end editing")
                    }
                }
            }
            if theTextFieldTruth == 5 {
                performSegue(withIdentifier: "toCityState", sender: nil)
                return false
            } else {
                showOkayAlert(title: "", message: "this is a desperate attempt to dismiss the keyboard.") { (_) in
                    self.performSegue(withIdentifier: "toCityState", sender: nil)
                }
                return false
            }
        }
        return true
    }
}
