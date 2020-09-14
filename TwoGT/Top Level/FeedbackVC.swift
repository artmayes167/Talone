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
            return UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous"
        }
    }
    var feedback: String?
}

class FeedbackVC: UIViewController {
    
    @IBOutlet weak var viewControllerNameLabel: UILabel!
    @IBOutlet weak var feedbackTextView: DesignableTextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var doneButtonTop: NSLayoutConstraint!
    @IBOutlet weak var doneButton: DesignableButton!
    
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
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let e = elements, let i = e.identifier, let keyEs = e.elements else { fatalError() }
        topViewControllerIdentifier = i
        keyElements = keyEs
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
    
    @IBAction func submitFeedback(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { fatalError() }
        let feedback = Feedback()
        feedback.identifier = topViewControllerIdentifier
        feedback.userId = user.uid
        feedback.feedback = feedbackTextView.text
        // submit
    }
    
    @IBAction func doneEditingText(_ sender: Any) {
        feedbackTextView.resignFirstResponder()
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


extension FeedbackVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneButtonTop.constant = 60
        UIView.animate(withDuration: 0.2) {
            self.doneButton.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        doneButtonTop.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.doneButton.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
}
