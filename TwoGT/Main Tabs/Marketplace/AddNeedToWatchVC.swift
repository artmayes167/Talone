//
//  AddNeedToWatchVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/24/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class AddNeedToWatchModel: NSObject {
    func storeWatchingNeedToDatabase(item: NeedsBase.NeedItem, creationManager: PurposeCreationManager, controller: UIViewController) {
        let c = creationManager
        let needItem = item
        guard let loc: SearchLocation = c.getLocationOrNil() else { fatalError() }
        // if neither need-type nor location is selected, display an error message
        guard let user = Auth.auth().currentUser else { fatalError() } //

        let need = NeedsDbWriter.NeedItem(category: needItem.category, headline: c.getHeadline() ?? needItem.headline,
                                          description: c.getDescription() ?? needItem.description,
                                          validUntil: needItem.validUntil, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                let n = Need.createNeed(item: need)
                n.parentNeedItemId = needItem.id
                try? CoreDataGod.managedContext.save()
                DispatchQueue.main.async {
                    controller.view.makeToast("you have successfully created a `need`!".taloneCased(), duration: 2.0, position: .center) {_ in
                        // TODO: - Create unwind segue to my needs
                        controller.performSegue(withIdentifier: "unwindToMyNeeds", sender: nil)
                    }
                }
                
            } else {
                controller.showOkayAlert(title: "".taloneCased(), message: "Error while adding a Need in ViewIndividualNeed. Error: \(error!.localizedDescription)".taloneCased(), handler: nil)
            }
        })
    }
    
    func storeWatchingHaveToDatabase(item: NeedsBase.NeedItem, creationManager: PurposeCreationManager, controller: UIViewController) {
        let c = creationManager
        let needItem = item
        guard let loc: SearchLocation = c.getLocationOrNil() else { fatalError() }
        // if neither need-type nor location is selected, display an error message
        guard let user = Auth.auth().currentUser else { fatalError() }

        let have = HavesDbWriter.HaveItem(category: needItem.category, headline: c.getHeadline() ?? needItem.headline,
                                          description: c.getDescription() ?? needItem.description,
                                          validUntil: needItem.validUntil, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: DefaultsKeys.userHandle.rawValue) ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                let _ = Have.createHave(item: have)
                let newCD = Need.createNeed(item: needItem)
                newCD.parentHaveItemId = have.id
                try? CoreDataGod.managedContext.save()
                DispatchQueue.main.async {
                    controller.view.makeToast("you have successfully created a `have`!".taloneCased(), duration: 2.0, position: .center) {_ in
                        controller.performSegue(withIdentifier: "unwindToMyHaves", sender: nil)
                    }
                }
                
            } else {
                controller.showOkayAlert(title: "".taloneCased(), message: "Error while adding a Have. Error: \(error!.localizedDescription)".taloneCased(), handler: nil)
            }
        })
    }
}

class AddNeedToWatchVC: UIViewController {

    @IBOutlet weak var headlineTextField: DesignableTextField!
    @IBOutlet weak var descriptionTextView: ActiveTextView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet var endEditingGestureRecognizer: UITapGestureRecognizer!
    
    var needItem: NeedsBase.NeedItem? {
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
    
    var model = AddNeedToWatchModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    func populateUI() {
        guard let c = creationManager else { return }
        switch c.currentCreationType() {
        case .need:
            infoLabel.text = "we will create a `need` to track this.  You can find it in `my needs`.".taloneCased()
        case .have:
            infoLabel.text = "we will create a `have` to track this.  You can find it in `my haves`.".taloneCased()
        default:
            fatalError()
        }
    }
    
    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let c = creationManager, let need = needItem else {
            fatalError()
        }
        
        _ = c.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        
        switch c.currentCreationType() {
        case .need:
            model.storeWatchingNeedToDatabase(item: need, creationManager: c, controller: self)
        case .have:
            model.storeWatchingHaveToDatabase(item: need, creationManager: c, controller: self)
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
