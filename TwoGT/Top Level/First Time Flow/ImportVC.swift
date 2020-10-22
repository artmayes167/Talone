//
//  ImportVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKCoreKit
import Firebase

class ImportVC: UIViewController, LoginButtonDelegate {
    @IBOutlet weak var loginButton: FBLoginButton?
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // check for valid token
        Profile.loadCurrentProfile { (profile, error) in
            if error == nil && profile != nil {
                self.performSegue(withIdentifier: "toYouIntro", sender: profile)
            } else {
                self.configureFBLogin()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.setValue(State.importVC.rawValue, forKey: State.stateDefaultsKey.rawValue)
    }
    
    func configureFBLogin() {
        if let l = loginButton {
            l.permissions = ["public_profile", "email"]
            l.delegate = self
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        Profile.loadCurrentProfile { (profile, error) in
            if error == nil {
                self.performSegue(withIdentifier: "toYouIntro", sender: Profile.current)
            } else { // Error Handling
                self.showOkayOrCancelAlert(title: "oops", message: "the gods of facebook have spoken, and the answer is 'nope'.  continue without?") { (_) in
                    self.performSegue(withIdentifier: "toYouIntro", sender: profile)
                } cancelHandler: { _ in
                    /// I might add other options for importing info
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        /// unlikely this will be called
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toYouIntro" {
            if let profile = sender as? Profile, let vc = segue.destination as? IntroYouVC {
                vc.profile = profile
            }
        }
    }
}
