//
//  FeedbackVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class ViewControllerElements {
    var identifier: String?
    var elements: [String]?
}

class Feedback {
    var identifier: String?
    var userId: String?
    var handle: String {
        get {
            return UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous"
        }
    }
    var feedback: String?
}

class FeedbackVC: UIViewController {
    
    @IBOutlet weak var viewControllerNameLabel: UILabel!
    @IBOutlet weak var feedbackTextView: DesignableTextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var elements: ViewControllerElements?
    
    private var keyElements: [String] = [] {
        didSet {
            if isViewLoaded {
                var placeholderText = ""
                for s in keyElements {
                    placeholderText += (s + "\n\n")
                }
                feedbackTextView.text = placeholderText
            }
        }
    }
    
    private var topViewControllerIdentifier = "" {
        didSet {
            if isViewLoaded {
                viewControllerNameLabel.text = topViewControllerIdentifier
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let e = elements, let i = e.identifier, let keyEs = e.elements else { return }
        topViewControllerIdentifier = i
        keyElements = keyEs
    }
    
    @IBAction func submitFeedback(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { fatalError() }
        let feedback = Feedback()
        feedback.identifier = topViewControllerIdentifier
        feedback.userId = user.uid
        feedback.feedback = feedbackTextView.text
        // submit
        launchEmail(body: feedbackTextView.text)
    }
    
    @IBAction func copyEmailToClipboard(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = "artmayes167@icloud.com"
    }
    
    @IBAction func callArt(_ sender: Any) {
        DispatchQueue.main.async {
            if let url = URL(string:"tel:7736826910") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.showOkayAlert(title: "Can't Call", message: "You're probably running this on an ipod.  Trying to crash the app?  This is not your moment.", handler: nil)
                }
            } else {
                self.showOkayAlert(title: "", message: "Bad url", handler: nil)
            }
        }
    }
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toTextViewHelper" {
//            guard let vc = segue.destination as? TextViewHelperVC else { fatalError() }
//            vc.configure(textView: feedbackTextView, displayName: "general feedback", initialText: feedbackTextView.text)
//        }
//    }
}

extension FeedbackVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: feedbackTextView, displayName: "general feedback", initialText: feedbackTextView.text)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

 // MARK: -
extension FeedbackVC: MFMailComposeViewControllerDelegate {

    func launchEmail(body: String) {

        let emailTitle = "Feedback on " + topViewControllerIdentifier
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
