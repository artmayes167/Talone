//
//  LogInVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

// Only use touch/face ID, or passcode to enter app?  Like Venmo

class LogInVC: UIViewController { // , LoginButtonDelegate {
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        Profile.loadCurrentProfile { (profile, error) in
//            if error == nil {
//                self.performSegue(withIdentifier: "toMain", sender: nil)
//            }
//            // Error Handling
//
//        }
//
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        let loginButton = FBLoginButton()
//        loginButton.center = view.center
//        view.addSubview(loginButton)
//        loginButton.permissions = ["public_profile", "email"]
//        loginButton.delegate = self
//
//        guard let token = AccessToken.current else { return }
//        if !token.isExpired {
//        Profile.loadCurrentProfile { (profile, error) in
//            if error == nil {
//                self.performSegue(withIdentifier: "toMain", sender: nil)
//            }
//            // Error Handling
//
//        }
//                }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.performSegue(withIdentifier: "toMain", sender: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    @IBAction func unwindToLogIn( _ segue: UIStoryboardSegue) {

    }
}
