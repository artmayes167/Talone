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

        // Decide whether we need to create a Need for this; or we just associate the userId to the Have
        // object
        guard let c = creationManager, let item = haveItem else {
            fatalError()
        }
        switch c.currentCreationType() {
        case .need:
            storeJoiningNeedToDatabase(haveItem: item)
        case .have:
            storeJoiningHaveToDatabase(haveItem: item)
        default:
            print("Got to joinThisNeed in ViewIndividualNeedVC, without setting a creation type")
        }
    }

    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    private func storeJoiningNeedToDatabase(haveItem: HavesBase.HaveItem) {
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo()  else { fatalError()
        }

        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        
        let need = NeedsDbWriter.NeedItem(category: haveItem.category, headline: c.getHeadline() ?? haveItem.headline,
                                          description: c.getDescription() ?? haveItem.description,
                                          validUntil: haveItem.validUntil ?? Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60)), //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                let n = Need.createNeed(item: NeedItem.createNeedItem(item: need))
                c.setNeed(n)
                c.setNeedParentHave(Have.createHave(item: HaveItem.createHaveItem(item: haveItem)))
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = c.getSavedPurpose() {
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            self.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                                // TODO: - Create unwind segue to my needs
                                self.performSegue(withIdentifier: "unwindToMyNeeds", sender: nil)
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
                
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Need. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }
    
    private func storeJoiningHaveToDatabase(haveItem: HavesBase.HaveItem) {
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo() else { fatalError()
        }

        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.

        let have = HavesDbWriter.HaveItem(category: haveItem.category, headline: c.getHeadline() ?? haveItem.headline,
                                          description: c.getDescription() ?? haveItem.description,
                                          validUntil: haveItem.validUntil, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                let h = Have.createHave(item: HaveItem.createHaveItem(item: have))
                c.setHave(h)
                c.setHaveParentHave(Have.createHave(item: HaveItem.createHaveItem(item: haveItem)))
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = c.getSavedPurpose() {
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            self.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                                // TODO: - Create unwind segue to my needs
                                self.performSegue(withIdentifier: "unwindToMyNeeds", sender: nil)
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
                
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Need. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }

    @IBAction func sendCard(_ sender: Any) {
    }

    @IBAction func saveNotes(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
}

extension ViewIndividualHaveVC: UITextViewDelegate {

}
