//
//  EntryFlowVCCollection.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class EnterEmailVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submitEmailButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.setValue(State.enterEmail.rawValue, forKey: State.stateDefaultsKey.rawValue)
        //textField.text = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue) ?? ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOkayAlert(title: "READ EVERYTHING", message: String(format:"you're special. you're about to embark on an adventure in social evolution.  your feedback will determine what this app becomes, so use the feedback mechanism in the app to give me your thoughts at any time. \n\n and read the screens before you move on. if anything is unclear, let me know so i can fix it."), handler: nil)
    }
    
    @IBAction func submitEmail(_ sender: Any) {

        if let email = self.textField.text?.pure() {
            let actionCodeSettings = ActionCodeSettings() //https://talone.page.link/85EH
            actionCodeSettings.url = URL(string: "https://talone-23f99.firebaseapp.com")  //https://talone.page.link"
            // The sign-in operation has to always be completed in the app.
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName("com.example.android",
                                                     installIfNotAvailable: false, minimumVersion: "12")
            Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
                if let error = error {
                    self.showOkayAlert(title: "Error", message: error.localizedDescription, handler: nil)
                    return
                }
                // The link was successfully sent. Inform the user.
                // Save the email locally so you don't need to ask the user for it again
                // if they open the link on the same device.
                UserDefaults.standard.set(email, forKey: DefaultsKeys.taloneEmail.rawValue)
                self.showOkayAlert(title: "", message: "Check your email for link") { (_ action: UIAlertAction) in
                    self.performSegue(withIdentifier: "toVerification", sender: nil)
                }
            }
        } else {
            self.showOkayAlert(title: "", message: "Email can't be empty", handler: nil)
        }
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let t = textField.text {
            if t.contains("@") && t.contains(".") {
                submitEmailButton.isEnabled = true
            }
            if (t.count > 50) && string != "" { return false }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let t = textField.text {
            if t.contains("@") && t.contains(".") {
                submitEmailButton.isEnabled = true
            }
        }
    }
}

class VerificationVC: UIViewController {

    @IBOutlet weak var signInInfo: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var confirmStack: UIStackView!
    @IBOutlet weak var doneStack: UIStackView!
    
    @IBAction func submitVerification(_ sender: Any) {
        // Sign-in code here
        trySignInWithEmailLink()
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(passwordlessSignInSuccessful), name: NSNotification.Name(rawValue: "PasswordlessEmailNotificationSuccess"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSignInButtonState()
    }
    
    private func setStackState() {
        confirmStack.isHidden = true
        doneStack.isHidden = false
        view.layoutIfNeeded()
    }

    private func setSignInButtonState() {
        if let _ = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue),
            let _ = UserDefaults.standard.string(forKey: "Link") {
            signInButton.isEnabled = true
            signInInfo.isHidden = true
            setStackState()
        } else {
            signInButton.isEnabled = false
        }
    }

    private func trySignInWithEmailLink() {
        if let email = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue), let link = UserDefaults.standard.string(forKey: "Link") {
            Auth.auth().signIn(withEmail: email, link: link) { (result , error) in
                if let error = error {
                    self.showOkayAlert(title: "", message: error.localizedDescription) { (_ action: UIAlertAction) in
                        // TODO: Check the error and invalidate link only if the error is specifically about
                        // the link (e.g. expired, already used etc.)
                        UserDefaults.standard.set(nil, forKey: "Link")
                        // navigate back
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                } else if let r = result {
                    UserDefaults.standard.setValue(r.user.uid, forKey: DefaultsKeys.uid.rawValue)
                    self.view.makeToast("You have successfully signed up!".taloneCased(), duration: 2.0, position: .center) { (_) in
                        self.performSegue(withIdentifier: "toHandle", sender: nil)
                    }
                }
            }
        } else {
            self.showOkayAlert(title: "", message: "Looks like we don't have a proper email or link after all...") { (_ action: UIAlertAction) in
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func passwordlessSignInSuccessful() {
        setStackState()
        setSignInButtonState()
    }
}

class EnterHandleVC: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(State.enterHandle.rawValue, forKey: State.stateDefaultsKey.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }

    @IBAction func submitHandle(_ sender: UIButton) {
        guard let t = textField.text, !(t.count < 4)  else {
            showOkayAlert(title: "Oops".taloneCased(), message: "Please choose a handle with 4 or more characters".taloneCased()) { _ in }
            return
        }
        let handle = t.pure()
        // TODO: - Set the handle on the back end
        // completion
        UserDefaults.standard.setValue(handle, forKey: DefaultsKeys.userHandle.rawValue)
        UserDefaults.standard.synchronize() // to prevent a crash
        guard let email = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue), let uid = UserDefaults.standard.string(forKey: DefaultsKeys.uid.rawValue) else { fatalError() }
        // create user.
        let _ = CoreDataGod.user
        _ = Email.create(name: DefaultsKeys.taloneEmail.rawValue, emailAddress: email, uid: uid)
        
        showOkayAlert(title: "Welcome, \(textField.text!)".taloneCased(), message: String(format: "as an elite tester, you can provide feedback from the dashboard, or call me directly from there. remember that your feedback will generate what this app becomes. \n\nwelcome to Talone.".taloneCased())) { _ in
            self.performSegue(withIdentifier: "toImport", sender: nil)
        }
    }
}
