//
//  InviteATesterVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

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
        launchOwnerEmail(subject: "\(AppDelegateHelper.user.handle)) Inviting A Tester!", body: str)
    }
}

extension InviteATesterVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes".taloneCased(), initialText: "")
        return false
    }
}
