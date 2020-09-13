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

class EnterEmailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmEmailExistsAlready: DesignableButton!

    @IBAction func submitEmail(_ sender: Any) {

        if let email = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let actionCodeSettings = ActionCodeSettings() //https://talone.page.link/85EH
            actionCodeSettings.url = URL(string: "https://talone-23f99.firebaseapp.com")  //https://talone.page.link"
            // The sign-in operation has to always be completed in the app.
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName("com.example.android",
                                                     installIfNotAvailable: false, minimumVersion: "12")
            Auth.auth().sendSignInLink(toEmail: email,
                                       actionCodeSettings: actionCodeSettings) { error in
                                        if let error = error {
                                            self.showOkayAlert(title: "Error", message: error.localizedDescription, handler: nil)
                                            return
                                        }
                                        // The link was successfully sent. Inform the user.
                                        // Save the email locally so you don't need to ask the user for it again
                                        // if they open the link on the same device.
                                        UserDefaults.standard.set(email, forKey: "Email")
                                        self.showOkayAlert(title: "", message: "Check your email for link") { (_ action: UIAlertAction) in
                                            self.performSegue(withIdentifier: "toVerification", sender: nil)
                                        }
            }
        } else {
            self.showOkayAlert(title: "", message: "Email can't be empty", handler: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = UserDefaults.standard.string(forKey: "Email") ?? ""
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmEmailExistsAlready.isEnabled = UserDefaults.standard.string(forKey: "Link") != nil ? true : false
    }
}

class EnterVerificationVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var signInInfo: UILabel!
    @IBOutlet weak var signInButton: UIButton!

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func setSignInButtonState() {
        if let _ = UserDefaults.standard.string(forKey: "Email"),
            let _ = UserDefaults.standard.string(forKey: "Link") {
            signInButton.isEnabled = true
            signInInfo.isHidden = true
        } else {
            signInButton.isEnabled = false
        }
    }

    private func trySignInWithEmailLink() {
        if let email = UserDefaults.standard.string(forKey: "Email"), let link = UserDefaults.standard.string(forKey: "Link") {
            Auth.auth().signIn(withEmail: email, link: link) { (_, error) in
                if let error = error {
                    self.showOkayAlert(title: "", message: error.localizedDescription) { (_ action: UIAlertAction) in
                        // TODO: Check the error and invalidate link only if the error is specifically about
                        // the link (e.g. expired, already used etc.)
                        UserDefaults.standard.set(nil, forKey: "Link")
                        // navigate back
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                } else {
                    self.view.makeToast("You have successfully signed up!", duration: 2.0, position: .center) { (_) in
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
        setSignInButtonState()
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