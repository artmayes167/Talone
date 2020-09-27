//
//  LogInVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import LocalAuthentication
import FBSDKCoreKit
import Firebase

// Only use touch/face ID, or passcode to enter app?  Like Venmo

class LogInVC: UIViewController { //, LoginButtonDelegate {
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

//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfAuthenticatedAndProgress()
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
    
    func checkIfAuthenticatedAndProgress() {

        // May want to look at deleting a user
        if Auth.auth().currentUser?.isEmailVerified ?? false, (/*Auth.auth().currentUser?.isAnonymous ??*/ false) == false  {
            print("Email verified!!! User not anonymous!")
            authenticationWithTouchID() { (success, error) in
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if success {
                    // May move to AppDelegate
                    DispatchQueue.main.async() {
                        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                        let mainStoryboard = UIStoryboard(name: "NoHome", bundle: nil)
                        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "Main App VC") as! BaseSwipeVC
                        mainVC.view.alpha = 0
                        appDelegate.window?.rootViewController = mainVC
                        appDelegate.window?.makeKeyAndVisible()
                        UIView.animate(withDuration: 0.5) {
                            mainVC.view.alpha = 1
                        }
                    }
                } else if let e = error {
                    DispatchQueue.main.async() {
                        self.showOkayOrCancelAlert(title: "Something went wrong.", message: "Try again?", okayHandler: { (_) in
                            self.checkIfAuthenticatedAndProgress()
                        }, cancelHandler: { (_) in
                            fatalError("\(e.localizedDescription)")
                        })
                    }
                } else {
                    DispatchQueue.main.async() {
                        self.showOkayOrCancelAlert(title: "Something went wrong.", message: "Try again?", okayHandler: { (_) in
                            self.checkIfAuthenticatedAndProgress()
                        }, cancelHandler: { (_) in
                            fatalError("No success or error, just unanticipated failure.")
                        })
                    }
                }
            }
        } else {
            DispatchQueue.main.async() {
                self.performSegue(withIdentifier: "toEnterEmail", sender: nil)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.performSegue(withIdentifier: "toMain", sender: nil)
    }
    
    func authenticationWithTouchID(completion: @escaping (Bool, Error?) -> Void) {
           let localAuthenticationContext = LAContext()
           localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"

           var authorizationError: NSError?
           let reason = "Authentication required to access the secure data"

           if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
               
               localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                   
                   if success {
                        DispatchQueue.main.async() {
                            self.showOkayAlert(title: "Success", message: "Authenticated succesfully!") { (_) in
                                completion(success, evaluateError)
                            }
                       }
                   } else {
                       // Failed to authenticate
                       completion(success, evaluateError)
                   
                   }
               }
           } else {
               completion(false, authorizationError)
           }
       }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    @IBAction func unwindToLogIn( _ segue: UIStoryboardSegue) {

    }
}
