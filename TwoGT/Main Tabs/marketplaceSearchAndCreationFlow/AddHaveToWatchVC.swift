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
        let have = item
        guard let email = CoreDataGod.user.emails?[0], let emailStr = email.emailString else { return }

        // User is watching the given have. No need is created
        HavesDbWriter().watchHave(item, usingHandle: CoreDataGod.user.handle!, email: emailStr) { (error) in
            if error == nil {
                controller.view.makeToast("You have successfully linked to \(have.owner)'s have".taloneCased(), duration: 2.0, position: .center) {_ in
                    // TODO: - Create unwind segue to my needs
                    controller.performSegue(withIdentifier: "unwindToWarehouse", sender: nil)
                }
            } else {
                controller.showOkayAlert(title: "Nope", message: "Error while linking to a have. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }

    func storeWatchingHaveToDatabase(item: HavesBase.HaveItem, creationManager: PurposeCreationManager, controller: UIViewController) {

        let c = creationManager
        let haveItem = item

        /// Create new Db needItem, based on the parent Have's haveItem
        let h = HavesDbWriter.HaveItem(category: haveItem.category, headline: c.getHeadline() ?? haveItem.headline,
                                          description: c.getDescription() ?? haveItem.description,
                                          validUntil: haveItem.validUntil ?? Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60)), //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: CoreDataGod.user.uid!,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: haveItem.locationInfo))

        let havesWriter = HavesDbWriter()
        /// Create a new backend need
        havesWriter.addHave(h, completion: { error in
            if error == nil {
                // Create CD Have and HaveItem
                _ = Have.createHave(item: h)
                DispatchQueue.main.async {
                    controller.view.makeToast("You have successfully created a Have!", duration: 2.0, position: .center) {_ in
                        // TODO: - Create unwind segue to my needs
                        controller.performSegue(withIdentifier: "unwindToWarehouse", sender: nil)
                    }
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
    @IBOutlet weak var trackLabel: UILabel!
    //@IBOutlet weak var infoLabel: UILabel!
   // @IBOutlet var endEditingGestureRecognizer: UITapGestureRecognizer!

    var haveItem: HavesBase.HaveItem? {
        didSet {
            if isViewLoaded {
                populateUI()
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
        guard let h = haveItem else { return }
        if  let headline = h.headline, !headline.isEmpty {
            trackLabel.text = headline
        } else if !h.category.isEmpty {
            trackLabel.text = "tracking" + h.category
        } else {
            trackLabel.text = "tracking" + h.owner + "'s have"
        }
    }

    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }

    @IBAction func save(_ sender: Any) {
        guard let c = creationManager, let have = haveItem else {
            fatalError()
        }

        _ = c.setHeadline(headlineTextField.text, description: descriptionTextView.text)

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
