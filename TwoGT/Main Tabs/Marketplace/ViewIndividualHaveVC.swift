//
//  ViewIndividualHaveVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class ViewIndividualHaveVC: UIViewController {
    var haveItem: HavesBase.HaveItem? {
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

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var doYouLabel: UILabel!

    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!
    @IBOutlet weak var joinThisHaveButton: DesignableButton!

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if let owner = haveItem?.owner {
            headerTitleLabel.text = String(format: "%@'s Have", owner)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()

    }

    func populateUI() {
        guard let n = haveItem?.category, let cityState = creationManager?.getLocationOrNil() else { return }
        guard let t = creationManager?.currentCreationTypeString() else { fatalError() }
        let str = "Do you " + t + "..."
        doYouLabel.text = str
        locationLabel.text = String(format: "%@ in %@", n, cityState.displayName())
        needDescriptionTextView.text = haveItem?.description
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

     // MARK: - Actions

    @IBAction func showLinkedHaves(_ sender: Any) {
    }

    @IBAction func joinThisHave(_ sender: Any) {
        // show textView for Headline and description (Required?)
        // Create a Have in the database linked to the current Have

        performSegue(withIdentifier: "toAddHeadline", sender: nil)
    }

    @IBAction func sendCard(_ sender: Any) {
        sendArbitraryCardToHaveOwner()
    }

    @IBAction func seeCard(_ sender: Any) {
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddHeadline" {
            guard let vc = segue.destination as? AddHaveToWatchVC else { fatalError() }
            vc.creationManager = creationManager
            vc.haveItem = haveItem
        }
    }

    @IBAction func unwindToViewIndividualHaveVC( _ segue: UIStoryboardSegue) {}

//    private func joinTheHave() {
//
//        guard let have = haveItem else { return }
//
//        NeedsDbWriter().createNeedAndJoinHave(have, usingHandle: AppDelegate.user.handle ?? "Anonymous") { (error, needItem) in
//            if error == nil {
//                // Show success
//                self.view.makeToast("Created a need and linked it to this Have", duration: 2.0, position: .center) {_ in
//                }
//                // Since we do not navigate away from this view, prevent user from creating another need.
//                self.joinThisHaveButton.isEnabled = false
//
//            }
//        }
//
//    }

    private func sendArbitraryCardToHaveOwner() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let haveItemCreatorUid = haveItem?.createdBy else { return }

        let cards = AppDelegate.user.cardTemplates // [Card]
        if cards.count == 0 { return }
        let card = cards[0] // TODO: temporary solution

        let handle = AppDelegate.user.handle ?? "Anonymous"
        let recipientHandle = haveItem?.owner ?? "Anonymous"
        let cardInstance = CardTemplateInstance.create(card: card, codableCard: nil, fromHandle: handle, toHandle: recipientHandle, message: "This is placeholder message that user should probably define themselves.")
        let data = GateKeeper().buildCodableInstanceAndEncode(instance: cardInstance)
        // TODO: Move this logic to another utility class.
        var fibCard = CardsBase.FiBCardItem(createdBy: userId, createdFor: haveItemCreatorUid, payload: data.base64EncodedString(), owner: handle)

        CardsDbWriter().addCard(fibCard) { error in
            if error != nil {
                print(error)
            }
        }
    }

}

extension ViewIndividualHaveVC: UITextViewDelegate {

}
