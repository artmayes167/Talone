//
//  MarketplaceModel.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/22/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

class MarketplaceModel: NSObject {
    var creationManager: PurposeCreationManager?
    
    convenience init(creationManager: PurposeCreationManager) {
        self.init()
        self.creationManager = creationManager
    }
    
    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    func storeNeedToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let need: NeedsBase.NeedItem = self.createNeedItem()

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                let n = Need.createNeed(item: NeedItem.createNeedItem(item: need))
                self.creationManager?.setNeed(n)
                _ = self.creationManager?.prepareForSave()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = self.creationManager?.getSavedPurpose() { // adds to needs
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            controller?.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                                controller?.performSegue(withIdentifier: "unwindToMyNeeds", sender: nil)
                                controller?.hideSpinner()
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
                
            } else {
                controller?.showOkayAlert(title: "", message: "Error while adding a Need in Marketplace. Error: \(error!.localizedDescription)") { (_) in
                    controller?.hideSpinner()
                }
            }
        })
    }

    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    func storeHaveToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let have: HavesBase.HaveItem = self.createHaveItem()
        let havesWriter = HavesDbWriter()

        havesWriter.addHave(have, completion: { [unowned controller] error in
            if error == nil {
                let h = Have.createHave(item: HaveItem.createHaveItem(item: have))
                self.creationManager?.setHave(h)
                _ = self.creationManager?.prepareForSave()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                if let p = self.creationManager?.getSavedPurpose() { // adds to have
                    AppDelegate.user.addToPurposes(p)
                    if appDelegate.save() {
                        DispatchQueue.main.async {
                            controller?.view.makeToast("You have successfully created a Have!", duration: 2.0, position: .center) {_ in
                                controller?.performSegue(withIdentifier: "unwindToMyHaves", sender: nil)
                                controller?.hideSpinner()
                            }
                        }
                    } else {
                        fatalError()
                    }
                } else {
                    fatalError()
                }
            } else {
                controller?.showOkayAlert(title: "", message: "Error while adding a Have. Error: \(error!.localizedDescription)") { (_) in
                    controller?.hideSpinner()
                }
            }
        })
    }
    
    private func checkPreconditionsAndAlert(light: Bool, controller: UIViewController?) -> Bool {
        if !(creationManager?.areAllRequiredFieldsFilled(light: light) ?? false) {
            controller?.showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return false
        }
        return true
    }
    
    // MARK: Private Creation Functions
    private func createNeedItem() -> NeedsBase.NeedItem {
        /// create new needs
        guard let loc = creationManager?.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country, let cat = creationManager?.getCategory()?.firebaseValue() else { fatalError() }
        let locData = NeedsDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = creationManager?.getHeadline()
        let desc = creationManager?.getDescription()
        let uid = Auth.auth().currentUser?.uid ?? "Anonymous"
        let need = NeedsDbWriter.NeedItem(category: cat, headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegate.user.handle ?? "AnonymousUser", createdBy: uid, locationInfo: locData)
        return need
    }
    
    private func createHaveItem() -> HavesBase.HaveItem {
        /// create new needs
        guard let loc = creationManager?.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country, let cat = creationManager?.getCategory()?.firebaseValue() else { fatalError() }
        let locData = HavesDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = creationManager?.getHeadline()
        let desc = creationManager?.getDescription()
        let uid = Auth.auth().currentUser?.uid ?? "Anonymous"
        let have = HavesDbWriter.HaveItem(category: cat, headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegate.user.handle ?? "AnonymousUser", createdBy: uid, locationInfo: locData)
        return have
    }
   
   private func getPrimaryEmail() -> String {
       var emailString = "artmayes167@icloud.com"
       if let primaryEmail: Email = AppDelegate.user.emails.first(where: { $0.title == DefaultsKeys.taloneEmail.rawValue})  {
               if let pEmail = primaryEmail.emailString {
               emailString = pEmail
           } else {
               print("Talone email not saved to User")
               emailString = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue) ?? emailString
           }
       } else {
           emailString = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue) ?? emailString
       }
       return emailString
   }
}
