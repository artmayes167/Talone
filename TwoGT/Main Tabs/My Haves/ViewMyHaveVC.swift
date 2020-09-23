//
//  ViewMyHaveVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/19/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Toast_Swift

class ViewMyHaveVC: UIViewController {

    var have: Have? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }

    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var doYouLabel: UILabel!
    @IBOutlet weak var haveDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!

    // MARK: - IBActions
    @IBAction func deleteHave(_ sender: Any) {
        deleteCurrentHave()
    }

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let owner = have?.haveItem?.owner ?? AppDelegate.user.handle {
            headerTitleLabel.text = String(format: "%@'s Have", owner)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }

    func populateUI() {
        guard let c = have?.haveItem?.category, let cityState = have?.purpose?.cityState else { return }
        locationLabel.text = String(format: "%@ in %@", c, cityState.displayName())
        haveDescriptionTextView.text = have?.haveItem?.desc ?? "No description"
        view.layoutIfNeeded()
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

    private func deleteCurrentHave() {
        guard let haveItem = have?.haveItem else { return }

        have?.deleteHave()

        HavesDbWriter().deleteHave(id: haveItem.id!, creator: haveItem.createdBy ?? "") { error in
            if error == nil {
                self.view.makeToast("You have Deleted the Have", duration: 1.0, position: .center) {_ in
                    self.performSegue(withIdentifier: "dismissToMyHaves", sender: self)
                }
            } else {
                self.showOkayAlert(title: "Error", message: "Error while deleting have. Error: \(error!.localizedDescription)", handler: nil)
            }

        }
    }
}
