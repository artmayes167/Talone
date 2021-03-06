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
    
    private var loc: CityStateSearchVC.Loc!
    private var cat: NeedType!
    private var controller: CreateNewItemVC!
    
    convenience init(controller: CreateNewItemVC, location: CityStateSearchVC.Loc, category: NeedType) {
        self.init()
        self.loc = location
        self.cat = category
        self.controller = controller
    }
    
    func storeNeedToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let need: NeedsBase.NeedItem = self.createNeedItem()

        let needsWriter = NeedsDbWriter()
        needsWriter.addNeed(need, completion: { [unowned controller] error in
            if error == nil {
                let _ = Need.createNeed(item: need)
                CoreDataGod.save()
                DispatchQueue.main.async {
                    controller?.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                        controller?.hideSpinner()
                        controller?.dismiss(animated: true, completion: nil)
                    }
                }
                
            } else {
                controller?.showOkayAlert(title: "", message: "Somebody screwed up. Error: \(error!.localizedDescription)") { (_) in
                    controller?.hideSpinner()
                }
            }
        })
    }

    func storeHaveToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let have: HavesBase.HaveItem = self.createHaveItem()
        let havesWriter = HavesDbWriter()

        havesWriter.addHave(have, completion: { [unowned controller] error in
            if error == nil {
                let _ = Have.createHave(item: have)
                CoreDataGod.save()
                DispatchQueue.main.async {
                    controller?.view.makeToast("You have successfully created a Have!", duration: 2.0, position: .center) {_ in
                        controller?.hideSpinner()
                        controller?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                controller?.showOkayAlert(title: "", message: "Somebody screwed up. Error: \(error!.localizedDescription)") { (_) in
                    controller?.hideSpinner()
                }
            }
        })
    }
    
    // MARK: Private Creation Functions
    private func createNeedItem() -> NeedsBase.NeedItem {
        /// create new needs
        let city = loc.city
        let state = loc.state
        let country = loc.country
        
        let locData = NeedsDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = controller.headlineTextField.text
        let desc = controller.descriptionTextView.text
        let uid = (Auth.auth().currentUser?.uid ?? AppDelegateHelper.user.uid)!
        let need = NeedsDbWriter.NeedItem(category: cat.firebaseValue(), headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegateHelper.user.handle!, createdBy: uid, locationInfo: locData)
        return need
    }
    
    private func createHaveItem() -> HavesBase.HaveItem {
        /// create new have
        let city = loc.city
        let state = loc.state
        let country = loc.country
        
        let locData = HavesDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = controller.headlineTextField.text
        let desc = controller.descriptionTextView.text
        let uid = (Auth.auth().currentUser?.uid ?? CoreDataGod.user.uid)!
        let have = HavesDbWriter.HaveItem(category: cat.firebaseValue(), headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegateHelper.user.handle!, createdBy: uid, locationInfo: locData)
        return have
    }
   
   private func getPrimaryEmail() -> String {
        var emailString: String = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue)!
        let e = AppDelegateHelper.user.emails ?? []
        if !e.isEmpty {
            if let primaryEmail: Email = e.first(where: { $0.title == DefaultsKeys.taloneEmail.rawValue} )  {
                emailString = primaryEmail.emailString!
            }
        }
        return emailString
    }
}


class MarketplaceModelOld: NSObject {
    var creationManager: PurposeCreationManager?
    
    convenience init(creationManager: PurposeCreationManager) {
        self.init()
        self.creationManager = creationManager
    }
    
    func storeNeedToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let need: NeedsBase.NeedItem = self.createNeedItem()

        let needsWriter = NeedsDbWriter()
        needsWriter.addNeed(need, completion: { [unowned controller] error in
            if error == nil {
                let _ = Need.createNeed(item: need)
                CoreDataGod.save()
                self.successFor("Need", controller: controller)
            } else {
                self.failureFor("Need", controller: controller, with: error)
            }
        })
    }

    func storeHaveToDatabase(controller: UIViewController?) {
        controller?.showSpinner()
        let have: HavesBase.HaveItem = self.createHaveItem()
        let havesWriter = HavesDbWriter()

        havesWriter.addHave(have) { [unowned controller] error in
            if error == nil {
                let _ = Have.createHave(item: have)
                CoreDataGod.save()
                self.successFor("Have", controller: controller)
            } else {
                self.failureFor("Have", controller: controller, with: error)
            }
        }
    }
    
    private func successFor(_ string: String, controller: UIViewController?) {
        DispatchQueue.main.async {
            controller?.view.makeToast("You have successfully created a \(string)!", duration: 2.0, position: .center) {_ in
                controller?.performSegue(withIdentifier: "unwindToWarehouse", sender: nil)
                controller?.hideSpinner()
            }
        }
    }
    
    private func failureFor(_ string: String, controller: UIViewController?, with error: Error?) {
        DispatchQueue.main.async {
            controller?.showOkayAlert(title: "", message: "Error while adding a \(string). Error: \(error!.localizedDescription)") { (_) in
                controller?.hideSpinner()
            }
        }
    }
    
    // MARK: Private Creation Functions
    private func createNeedItem() -> NeedsBase.NeedItem {
        /// create new needs
        guard let loc = creationManager?.getLocationOrNil(), let cat = creationManager?.getCategory()?.firebaseValue() else { fatalError() }
        let city = loc.city
        let state = loc.state
        let country = loc.country
        
        let locData = NeedsDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = creationManager?.getHeadline()
        let desc = creationManager?.getDescription()
        let uid = (Auth.auth().currentUser?.uid ?? AppDelegateHelper.user.uid)!
        let need = NeedsDbWriter.NeedItem(category: cat, headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegateHelper.user.handle!, createdBy: uid, locationInfo: locData)
        return need
    }
    
    private func createHaveItem() -> HavesBase.HaveItem {
        /// create new needs
        guard let loc = creationManager?.getLocationOrNil(), let cat = creationManager?.getCategory()?.firebaseValue() else { fatalError() }
        let city = loc.city
        let state = loc.state
        let country = loc.country
        
        let locData = HavesDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        let headline = creationManager?.getHeadline()
        let desc = creationManager?.getDescription()
        let uid = (Auth.auth().currentUser?.uid ?? CoreDataGod.user.uid)!
        let have = HavesDbWriter.HaveItem(category: cat, headline: headline, description: desc, validUntil: defaultValidUntilDate, owner: AppDelegateHelper.user.handle!, createdBy: uid, locationInfo: locData)
        return have
    }
   
   private func getPrimaryEmail() -> String {
        var emailString: String = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue)!
        let e = AppDelegateHelper.user.emails ?? []
        if !e.isEmpty {
            if let primaryEmail: Email = e.first(where: { $0.title == DefaultsKeys.taloneEmail.rawValue} )  {
                emailString = primaryEmail.emailString!
            }
        }
        return emailString
    }
}
