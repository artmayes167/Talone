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
    
    @IBOutlet weak var topImage: UIImageView!

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfAuthenticatedAndProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topImage.cycleOpacity()
    }
    
    /// Initial check that routes dragon to the noob flow according to state saved in `UserDefaults`, or replaces the navigation controller with the `BaseSwipeVC` as `window.root`
    func checkIfAuthenticatedAndProgress() {
        if let _ = UserDefaults.standard.string(forKey: DefaultsKeys.userHandle.rawValue), AppDelegate.stateManager.configureIntro() == nil, (Auth.auth().currentUser?.isEmailVerified ?? false) {
            print("Email verified!!! User not anonymous!")
            authenticationWithTouchID() { (success, error) in
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                    if success {
                        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                        let mainStoryboard = UIStoryboard(name: "NoHome", bundle: nil)
                        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "Main App VC") as! BaseSwipeVC
                        mainVC.view.alpha = 0
                        appDelegate.window?.rootViewController = mainVC
                        appDelegate.window?.makeKeyAndVisible()
                        UIView.animate(withDuration: 0.5) {
                            mainVC.view.alpha = 1
                        }
                    } else if let e = error {
                        self.showOkayOrCancelAlert(title: "Something went wrong: \(e.localizedDescription).".taloneCased(), message: "Try again?".taloneCased(), okayHandler: { (_) in
                            self.checkIfAuthenticatedAndProgress()
                        }, cancelHandler: { (_) in
                            
                        })
                    } else {
                        self.showOkayOrCancelAlert(title: "Something went wrong.".taloneCased(), message: "Try again?".taloneCased(), okayHandler: { (_) in
                            self.checkIfAuthenticatedAndProgress()
                        }, cancelHandler: { (_) in
                            fatalError("No success or error, just unanticipated failure.")
                        })
                    }
                }
            }
        } else {
            DispatchQueue.main.async() {
                /// This covers the two cases besides the email verification
                if let name = AppDelegate.stateManager.configureIntro() {
                    /// previously entered the noob train, and crashed
                    self.performSegue(withIdentifier: name.segueValue(), sender: nil)
                } else {
                    /// First time entering the noob train
                    self.performSegue(withIdentifier: "toEnterEmail", sender: nil)
                }
            }
        }
    }
    
    func authenticationWithTouchID(completion: @escaping (Bool, Error?) -> Void) {
           let localAuthenticationContext = LAContext()

           var authorizationError: NSError?
           let reason = "Authentication required to access the secure data"

           if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
               /// `deviceOwnerAuthentication` automagically handles fallback
               localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                   
                   if success {
                        DispatchQueue.main.async() {
                            self.showOkayAlert(title: "Success", message: "Authenticated succesfully!") { (_) in
                                completion(success, evaluateError)
                            }
                       }
                   } else {
                    self.authenticationWithTouchID(completion: completion)
                   }
               }
           } else {
            self.showOkayAlert(title: "nope", message: "This is probably a simulator error. check device capabilities before hitting okay.") { (_) in
                self.authenticationWithTouchID(completion: completion)
            }
           }
       }

    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
//
//    @IBAction func unwindToLogIn( _ segue: UIStoryboardSegue) {
//
//    }
}
