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

    @IBAction func joinThisNeed(_ sender: Any) {
        guard let c = creationManager else {
            fatalError()
        }
        switch c.currentCreationType() {
        case .need:
            storeJoiningNeedToDatabase()
        case .have:
            storeJoiningHaveToDatabase()
        default:
            print("Got to joinThisNeed in ViewIndividualNeedVC, without setting a creation type")
        }
        
    }

    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    private func storeJoiningNeedToDatabase() {
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo() else { fatalError()
        }
        guard let needItem = needItem else { fatalError() }
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.

        let need = NeedsDbWriter.NeedItem(category: needItem.category, headline: c.getHeadline() ?? needItem.headline,
                                          description: c.getDescription() ?? needItem.description,
                                          validUntil: needItem.validUntil, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                let n = Need.createNeed(item: NeedItem.createNeedItem(item: need))
                n.parentNeedItemId = needItem.id
                c.setNeed(n)
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
                self.showOkayAlert(title: "", message: "Error while adding a Need in ViewIndividualNeed. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }
    
    private func storeJoiningHaveToDatabase() {
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo() else { fatalError()
        }
        guard let needItem = needItem else { fatalError() }
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.

        let have = HavesDbWriter.HaveItem(category: needItem.category, headline: c.getHeadline() ?? needItem.headline,
                                          description: c.getDescription() ?? needItem.description,
                                          validUntil: needItem.validUntil, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: DefaultsKeys.userHandle.rawValue) ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                let h = Have.createHave(item: HaveItem.createHaveItem(item: have))
                
                c.setHave(h)
                let newCD = Need.createNeed(item: NeedItem.createNeedItem(item: needItem))
                newCD.parentHaveItemId = have.id
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

}

extension ViewIndividualNeedVC: UITextViewDelegate {

}
