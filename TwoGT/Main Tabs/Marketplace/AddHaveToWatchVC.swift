//
//  AddHaveToWatchVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/24/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class AddHaveToWatchModel: NSObject {
    func storeWatchingNeedToDatabase(item: HavesBase.HaveItem, creationManager: PurposeCreationManager, controller: UIViewController) {
        let c = creationManager
        let have = item

        let needsWriter = NeedsDbWriter()
        // add Need to DB
        needsWriter.createNeedAndJoinHave(have, usingHandle: AppDelegate.user.handle ?? "Anonymous") { (error, firebaseNeedItem) in
            if error == nil, let needItem = firebaseNeedItem {
                let n = Need.createNeed(item: NeedItem.createNeedItem(item: needItem))
                let h = HaveItem.createHaveItem(item: have)
                let _ = Have.createHave(item: h)
                n.parentHaveItemId = have.id
                c.setNeed(n)

                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = c.getSavedPurpose() {
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            controller.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                                // TODO: - Create unwind segue to my needs
                                controller.performSegue(withIdentifier: "unwindToMyNeeds", sender: nil)
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
                
            } else {
                controller.showOkayAlert(title: "Nope", message: "Error while adding a Need. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
    
    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    func storeWatchingHaveToDatabase(item: HavesBase.HaveItem, creationManager: PurposeCreationManager, controller: UIViewController) {
        
        let c = creationManager
        let haveItem = item
        
        guard let loc = c.getLocationOrNil()?.locationInfo(), let user = Auth.auth().currentUser  else { fatalError()
        }

        // if need-type nor location is not selected, display an error message
        
        /// Create new Db needItem, based on the parent Have's haveItem
        let h = HavesDbWriter.HaveItem(category: haveItem.category, headline: c.getHeadline() ?? haveItem.headline,
                                          description: c.getDescription() ?? haveItem.description,
                                          validUntil: haveItem.validUntil ?? Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60)), //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let havesWriter = HavesDbWriter()
        /// Create a new backend need
        havesWriter.addHave(h, completion: { error in
            if error == nil {
                // Create CD Have and HaveItem
                let cdHave = Have.createHave(item: HaveItem.createHaveItem(item: h))
                
                // Set have in creationManager
                c.setHave(cdHave)
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = c.getSavedPurpose() {
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            controller.view.makeToast("You have successfully created a Have!", duration: 2.0, position: .center) {_ in
                                // TODO: - Create unwind segue to my needs
                                controller.performSegue(withIdentifier: "unwindToMyHaves", sender: nil)
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
                
            } else {
                controller.showOkayAlert(title: "", message: "Error while adding a Have. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }
}

class AddHaveToWatchVC: UIViewController {

    @IBOutlet weak var headlineTextField: DesignableTextField!
    
    @IBOutlet weak var descriptionTextView: ActiveTextView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet var endEditingGestureRecognizer: UITapGestureRecognizer!
    
    
    var haveItem: HavesBase.HaveItem? {
        didSet {
            if isViewLoaded {
                //populateUI()
            }
        }
    }

    // Manages live activity in the app
    var creationManager: PurposeCreationManager? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }
    
    var model = AddHaveToWatchModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    func populateUI() {
        guard let c = creationManager else { return }
        switch c.currentCreationType() {
        case .need:
            infoLabel.text = "We will create a Need to track this Need.  You can find it in MyNeeds."
        case .have:
            infoLabel.text = "We will create a Have to track this Need.  You can find it in MyHaves."
        default:
            fatalError()
        }
    }
    
    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let c = creationManager, let have = haveItem else {
            fatalError()
        }
        let success = c.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        if !success { fatalError() }
        switch c.currentCreationType() {
        case .need:
            model.storeWatchingNeedToDatabase(item: have, creationManager: c, controller: self)
        case .have:
            model.storeWatchingHaveToDatabase(item: have, creationManager: c, controller: self)
        default:
            print("Got to joinThisNeed in ViewIndividualNeedVC, without setting a creation type")
        }
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
