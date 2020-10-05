//
//  ViewMyNeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/19/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewMyNeedVC: UIViewController {

    var need: Need? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }

    // Manages live activity in the app
    var creationManager: PurposeCreationManager?

    @IBOutlet weak var pageHeaderView: SecondaryPageHeader!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!

    // MARK: - - IBActions

    @IBAction func deleteNeed(_ sender: Any) {
        deleteCurrentNeed()
    }

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()

    }

    func populateUI() {
        guard let n = need?.category, let loc = need?.location else { return }
        locationLabel.text = n + " in " + loc.displayName()
        pageHeaderView.setTitleText(need?.headline ?? "No Headline!")
        needDescriptionTextView.text = need?.desc ?? "No Description!"
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

    private func deleteCurrentNeed() {
        guard let n = need else { return }
        let parentHave = n.parentHaveItemId
        let handle = CoreDataGod.user.handle

        n.deleteNeed()          // Remove from CoreData
        // Remove from Remote database
        NeedsDbWriter().deleteNeed(id: n.id!, userHandle: handle, associatedHaveId: parentHave) { error in
            if error == nil {
                self.view.makeToast("You have Deleted the Need".taloneCased(), duration: 1.0, position: .center) {_ in
                    self.performSegue(withIdentifier: "dismissToMyNeeds", sender: self)
                }
            } else {
                self.showOkayAlert(title: "Error".taloneCased(), message: "Error while deleting need. Error: \(error!.localizedDescription)".taloneCased(), handler: nil)
            }
        }
    }
}
