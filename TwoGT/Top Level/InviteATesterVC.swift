//
//  InviteATesterVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class InviteATesterVC: UIViewController {

    @IBOutlet weak var pageHeaderView: SecondaryPageHeader!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var personalNotesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageHeaderView.setTitleText("invite a tester")
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets()
        scrollView.contentInset = contentInset
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func sendToArt(_ sender: UIButton) {
        guard let e = emailTextField.text?.pure(), let n = realNameTextField.text?.pure() else {
            showOkayAlert(title: "nope", message: "try again?", handler: nil)
            return
        }
        
        if !e.contains("@") || !e.contains(".") {
            showOkayAlert(title: "nope", message: "try again?", handler: nil)
            return
        }
        
        if !(n.endIndex > "aaa".endIndex) {
            showOkayAlert(title: "nope", message: "try again?", handler: nil)
            return
        }
        let comments = personalNotesTextView.text.pure()
        let str = String(format: "Invitee email: %@ \n Invitee name: %@ \n Comments: %@", e, n, comments)
        launchEmail(body: str)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: -
extension InviteATesterVC: MFMailComposeViewControllerDelegate {

   func launchEmail(body: String) {

    let emailTitle = "\(String(describing: AppDelegate.user.handle)) Inviting A Tester!"
       let toRecipents = ["artmayes167@icloud.com"]
       let mc: MFMailComposeViewController = MFMailComposeViewController()
       mc.mailComposeDelegate = self
       mc.setSubject(emailTitle)
       mc.setMessageBody(body, isHTML: false)
       mc.setToRecipients(toRecipents)

       self.present(mc, animated: true, completion: nil)
   }

   func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
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
           self.showOkayAlert(title: "", message: message, handler: nil)
       }
   }
}
