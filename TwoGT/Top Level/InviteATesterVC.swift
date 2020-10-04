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

final class InviteATesterVC: UIViewController {

    /// custom view -- must call `.setTitleText()`
    @IBOutlet weak var pageHeaderView: SecondaryPageHeader!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var personalNotesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageHeaderView.setTitleText("invite a tester".taloneCased())
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func sendToArt(_ sender: UIButton) {
        let nopeTitle = "nope".taloneCased()
        let nopeMessage = "try again?".taloneCased()
        guard let e = emailTextField.text?.pure(), let n = realNameTextField.text?.pure() else {
            showOkayAlert(title: nopeTitle, message: nopeMessage, handler: nil)
            return
        }
        
        if !e.contains("@") || !e.contains(".") {
            showOkayAlert(title: nopeTitle, message: nopeMessage, handler: nil)
            return
        }
        if !(n.endIndex > "aaa".endIndex) {
            showOkayAlert(title: nopeTitle, message: nopeMessage, handler: nil)
            return
        }
        
        let comments = personalNotesTextView.text.pure()
        let str = String(format: "Invitee email: %@ \n Invitee name: %@ \n Comments: %@", e, n, comments)
        launchEmail(body: str)
    }
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
        self.showOkayAlert(title: "", message: message.taloneCased(), handler: nil)
       }
   }
}

extension InviteATesterVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes".taloneCased(), initialText: "")
        return false
    }
}
