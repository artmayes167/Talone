//
//  UIViewController+Extensions.swift
//  UsefulCode
//
//  Created by Mayes, Arthur E. on 2/18/19.
//  Copyright © 2019 Mayes, Arthur E. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UIViewController {
    
    @objc func getKeyElements() -> [String] {
        return []
    }
    
    /// Show an Alert with an "Ok" button, automatically set to use the Talone case rules.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert, `taloneCased()`
    ///   - message: The message for the Alert, `taloneCased()`
    func showOkayAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.taloneCased(), message: message.taloneCased(), preferredStyle: .alert)
        let action1 = UIAlertAction(title: "ok".taloneCased(), style: .cancel, handler: handler)
        alert.addAction(action1)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Show and Alert with an "Ok" button and a "Cancel" button.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert, `taloneCased()`
    ///   - message: The message for the Alert, `taloneCased()
    ///   - okayHandler: A block to execute when the user taps "Ok".
    func showOkayOrCancelAlert(title: String, message: String, okayHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.taloneCased(), message: message.taloneCased(), preferredStyle: .alert)
        let action1 = UIAlertAction(title: "ok".taloneCased(), style: .default, handler: okayHandler)
        let action2 = UIAlertAction(title: "cancel".taloneCased(), style: .cancel, handler: cancelHandler)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    /// Show and Alert with a "Retry" button and a "Cancel" button.
    ///
    /// - Parameters:
    ///   - title: The title for the Alert, `taloneCased()`
    ///   - message: The message for the Alert, `taloneCased()
    ///   - okayHandler: A block to execute when the user taps "Retry".
    func showRetryOrCancelAlert(title: String, message: String, retryHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.taloneCased(), message: message.taloneCased(), preferredStyle: .alert)
        let action1 = UIAlertAction(title: "retry".taloneCased(), style: .default, handler: retryHandler)
        let action2 = UIAlertAction(title: "cancel".taloneCased(), style: .cancel, handler: cancelHandler)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showAdminPasswordAlert(title: String, message: String, okayHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title.taloneCased(), message: message, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "****"
        }
        let saveAction = UIAlertAction(title: "enter".taloneCased(), style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let adminPass = UserDefaults.standard.string(forKey: "admin")
            if firstTextField.text == adminPass {
                okayHandler(alert)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "cancel".taloneCased(), style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
     // MARK: - Spinner Controls
    func showSpinner() {
        let helperBoard = UIStoryboard(name: "Helper", bundle: nil)
        let spinner = helperBoard.instantiateViewController(withIdentifier: "Spinner") as! SpinnerVC
        spinner.willMove(toParent: self)
        spinner.view.frame = UIScreen.main.bounds
        view.addSubview(spinner.view)
        addChild(spinner)
        spinner.didMove(toParent: self)
    }
    
    func hideSpinner() {
        for vc in children {
            if let s = vc as? SpinnerVC {
                s.willMove(toParent: nil)
                s.removeFromParent()
                s.view.removeFromSuperview()
            }
        }
    }
    
     // MARK: - TextViewHelper Presentation
    /// provides a less-annoying textView experience for me.
    func showTextViewHelper(textView: UITextView, displayName: String, initialText: String) {
        let helperBoard = UIStoryboard(name: "Helper", bundle: nil)
        let helper = helperBoard.instantiateViewController(withIdentifier: "TextView Helper") as! TextViewHelperVC
        helper.configure(textView: textView, displayName: displayName, initialText: initialText)
        view.endEditing(true)
        present(helper, animated: true, completion: nil)
    }
    
     // MARK: - CompleteAndSendCard Presentation
    /** you must include one of `interaction`, `haveItem` or `needItem`.
            This VC manages creation of cards, and provides a less-annoying textView experience for me.
    */
    func showCompleteAndSendCardHelper(card: CardTemplateInstance? = nil, haveItem: HavesBase.HaveItem? = nil, needItem: NeedsBase.NeedItem? = nil) {
        let helperBoard = UIStoryboard(name: "Helper", bundle: nil)
        let helper = helperBoard.instantiateViewController(withIdentifier: "New Card Helper") as! CompleteAndSendCardVC
        helper.configure(card: card, haveItem: haveItem, needItem: needItem)
        present(helper, animated: true, completion: nil)
        
    }
}

 // MARK: - default textField delegation implementation
extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// Call super on override
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let t = textField.text {
            if (t.count > 50) && string != "" { return false }
        }
        return true
    }
}

/// Add VCs to enable Toast.  NOT IMPLEMENTED OR USED YET -- may work better as an extension
class ModalContainerVC: UIViewController {
    func addViewController(_ vc: UIViewController) {
        vc.willMove(toParent: self)
        view.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    // Copy Toast code from BaseSwipeVC?
}

// MARK: -
extension UIViewController: MFMailComposeViewControllerDelegate {
    func launchEmail(to recipients: [String], subject: String = "", body: String) {
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("Talone: " + subject)
        mc.setMessageBody(body, isHTML: false)
        mc.setToRecipients(recipients)
        self.present(mc, animated: true, completion: nil)
   }
    
    func launchOwnerEmail(subject: String = "", body: String) {
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("Talone: " + subject)
        mc.setMessageBody(body, isHTML: false)
        mc.setToRecipients(["artmayes167@icloud.com"])
        self.present(mc, animated: true, completion: nil)
   }

   public func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
       var message = ""
       switch result {
       case .cancelled:
           message = "Mail cancelled"
       case .saved:
           message = "Mail saved"
       case .sent:
           message = "Mail sent"
       case .failed:
           message = "Mail sent failure: \(String(describing: error?.localizedDescription))."
       default:
           message = "Something unanticipated has occurred"
           break
       }
       self.dismiss(animated: true) {
        self.showOkayAlert(title: "", message: message.taloneCased(), handler: nil)
       }
   }
}
