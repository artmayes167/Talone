//
//  ViewIndividualNeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class ViewIndividualNeedVC: UIViewController {
    var needItem: NeedsBase.NeedItem? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }

    // Manages live activity in the app
    var creationManager: PurposeCreationManager?

    @IBOutlet weak var headerTitleLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var needTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let owner = needItem?.owner {
            headerTitleLabel.text = String(format: "%@'s Need", owner)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()

    }

    func populateUI() {
        guard let n = needItem?.category, let cityState = creationManager?.getLocationOrNil() else { return }
        needTypeLabel.text = n
        locationLabel.text = cityState.displayName()
        needDescriptionTextView.text = needItem?.description
    }

    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets()
        scrollView.contentInset = contentInset
    }

     // MARK: - Actions
    // Link in storyboard, if nothing else is done here
    @IBAction func joinThisNeed(_ sender: Any) {
        performSegue(withIdentifier: "toAddHeadline", sender: nil)
    }
    
    @IBAction func sendCard(_ sender: Any) {
        performSegue(withIdentifier: "toCompleteAndSendCardVC", sender: nil)
    }
    
    @IBAction func saveNotes(_ sender: Any) {
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddHeadline" {
            guard let vc = segue.destination as? AddNeedToWatchVC else { fatalError() }
            vc.creationManager = creationManager
            vc.needItem = needItem
        } else if segue.identifier == "toCompleteAndSendCardVC" {
            guard let vc = segue.destination as? CompleteAndSendCardVC else { fatalError() }
            vc.needItem = needItem
        }
    }

    @IBAction func unwindToViewIndividualNeedVC( _ segue: UIStoryboardSegue) {}
}

extension ViewIndividualNeedVC: UITextViewDelegate {

}
