//
//  FeedbackVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

class ViewControllerElements {
    var identifier: String?
    var elements: [String]?
}

class Feedback {
    var identifier: String?
    var userId: String?
    var handle: String {
        get {
            return CoreDataGod.user.handle!
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
        launchOwnerEmail(subject: "feedback", body: feedbackTextView.text)
    }
    
    @IBAction func copyEmailToClipboard(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = "talone.the.app@gmail.com"
    }
    
    @IBAction func callArt(_ sender: Any) {
        DispatchQueue.main.async {
            if let url = URL(string:"tel:7739451622") {
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
