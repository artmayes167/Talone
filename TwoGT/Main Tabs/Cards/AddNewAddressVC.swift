//
//  AddNewAddressVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/25/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AddNewAddressVC: UIViewController {
    
     // MARK: - IBOutlets
    
    @IBOutlet weak var labelTextField: DesignableTextField!
    @IBOutlet weak var street1TextField: DesignableTextField!
    @IBOutlet weak var street2TextField: DesignableTextField!
    @IBOutlet weak var cityStateTextField: DesignableTextField!
    @IBOutlet weak var zipTextField: DesignableTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showReplaceAlert() {
        showOkayOrCancelAlert(title: "Uh Oh", message: "An address with this label already exists. Replace??", okayHandler: { (_) in
            self.addAddress()
        }, cancelHandler: nil)
    }
    
    private func checkValidity() -> Bool {
        let outletCollection = [labelTextField, street1TextField, cityStateTextField, zipTextField]
        for tf in outletCollection {
            guard let x = tf!.text?.pure(), !x.isEmpty else {
                showOkayAlert(title: "", message: "Please complete all required fields.  So, everything except Address Line 2 needs to be filled in with something.  It doesn't have to be a real address, I suppose.  But we decided it shouldn't be empty.", handler: nil)
                return false
            }
        }
        return true
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        if checkValidity() {
            addAddress()
        }
    }
    
    func addAddress() {
      // 1
      let newAddress = Address(context: managedObjectContext)

      // 2
        newAddress.type = labelTextField.text?.pure()
        newAddress.street1 = street1TextField.text?.pure()
        newAddress.street2 = street2TextField.text?.pure()
        newAddress.city = city
        newAddress.state = state
        newAddress.zip = zipTextField.text?.pure()
        AppDelegate.user.addToAddresses(newAddress) // Make sure this works and is necessary

      // 3
        if saveContext() {
            performSegue(withIdentifier: "unwindToYou", sender: nil)
        }
    }
    
    func saveContext() -> Bool {
      do {
        try managedObjectContext.save()
        return true
      } catch {
        fatalError()
      }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCityState" {
            guard let vc = segue.destination as? CityStateSearchVC else { fatalError() }
            vc.unwindSegueIdentifier = "unwindToNewAddress"
        }
    }
    
    var city: String?
    var state: String?
    
    @IBAction func unwindToAddNewAddress( _ segue: UIStoryboardSegue) {
        if let vc = segue.source as? CityStateSearchVC {
            let loc = vc.selectedLocation
            guard let c = loc[.city], let s = loc[.state] else { fatalError() }
            city = c
            state = s
            cityStateTextField.text = c.capitalized + ", " + s.capitalized
        }
    }
    
    // MARK: - Keyboard Notifications
    var initialContentInset: UIEdgeInsets?
   @objc func keyboardWillShow(notification: NSNotification) {
       let userInfo = notification.userInfo!
       var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
       keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    if initialContentInset == nil {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        initialContentInset = contentInset
    }
       
       scrollView.contentInset = initialContentInset!
   }

   @objc func keyboardWillHide(notification: NSNotification) {
       let contentInset: UIEdgeInsets = initialContentInset!
       scrollView.contentInset = contentInset
   }
}

extension AddNewAddressVC {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityStateTextField {
            textField.resignFirstResponder()
            performSegue(withIdentifier: "toCityState", sender: nil)
        }
    }
}
