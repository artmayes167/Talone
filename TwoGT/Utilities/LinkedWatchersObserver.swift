//
//  LinkedWatchersObserver.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 10/4/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/** Certain VCs are interested to update their list views if linked needs count changes. MyHaves List shows count of linked needs. */
protocol LinkedWatchersCountChangeDetectable: UIViewController {
    func havesLinkedWatchersCountChanged()
}

/** Class that encapsulates functionality need to observe changes in user's Have items stored in Firestore */
class LinkedWatchersObserver {

    var haves: [Have] = []
    var reobservers = Set<UIViewController>()       // VCs that need to be notified if the count of linked needs in a have changes.
    var fetcher: HavesObserver = HavesDbFetcher()   // For testing: Override with a class that conforms to HavesObserver

    /**
     VCs interested to know the real-time changes to the count of linked needs of a Have should register for change events by calling this method.
        - parameters:
            - vc:ViewController that conforms to LinkedNeedsCountChangeDetectable protocol */
    func registerForUpdates(_ vc: LinkedWatchersCountChangeDetectable) {
        reobservers.insert(vc)
    }

    func deregisterForUpdates(_ vc: LinkedWatchersCountChangeDetectable) {
        reobservers.remove(vc)
    }

    func stopObservingHaveChanges() {
        fetcher.stopObserving()
    }

    /**
    Application shall call this method when the UI is interested to know real-time Firestore changes to Haves owned/posted by the current user. Any updates to the number of needs that are linked to any Have of the user will trigger a visible Toast. Certain VCs can also register to be further notified of the change by calling registerForUpdates() method.  Call stopObservingHaveChanges() when observation of Firestore is no longer needed.   */
    func startObservingHaveChanges() {

        fetcher.observeMyHaves { [self] fibHaveItems in

            var addedHaveWatchers = [String]()
            var changedHaves = [Have]()
            var isRedrawRequired = false

            // Get the latest haves from CD.
            getHaves()

            // Cross-reference user stubs (former child needs)
            for have in self.haves {                                        // CoreData Haves
                for fibHave in fibHaveItems where fibHave.id == have.id {   // Firebase Haves
                    if let watchers = fibHave.watchers {
                        var isChanged = false
                        changedHaves.append(have)   // for showing on UI

                        let cdWatchers = have.watchers ?? []

                        // First determine if there are any new userStubs that are missing from CD
                        // These are the people that have linked with this have.
                        for userStub in watchers {
                            var found = false
                            for cdUserStub in cdWatchers where (cdUserStub as! UserStub).uid == userStub.uid {
                                found = true
                                break
                            }
                            if found == false {
                                // create a new UserStub
                                _ = UserStub.create(fibData: userStub, linkedItem: have)
                                addedHaveWatchers.append(userStub.handle)
                                isChanged = true
                            }
                        }

                        // Then determine if there are userStubs being deleted requiring cleanup from CD.
                        // These are the people that have removed the link with this have.
                        for cdUserStub in cdWatchers {
                            let cdUserStub = cdUserStub as! UserStub
                            var found = false
                            for userStub in watchers where userStub.uid == cdUserStub.uid {
                                found = true
                                break
                            }
                            if found == false {
                                cdUserStub.delete()
                                isChanged = true
                            }
                        }
                        if isChanged {
                            CoreDataGod.save() // store changes to CD
                            isRedrawRequired = true
                        }
                    }
                }
            }
            if isRedrawRequired { notifyObservers() }
            notifyUserOfNewLinks(addedHaveWatchers, changedHaves)
        }
    }

    private func notifyUserOfNewLinks(_ owners: [String], _ haveItems: [Have]) {
        if owners.count > 0 {
            var str = ""
            let haveDesc = haveItems.count == 1 ? (haveItems[0].headline ?? haveItems[0].desc ?? "") : "haves."
            switch owners.count {
            case 1:
                str = "\(owners[0]) is interested in your \(haveDesc)"
            case 2:
                str = "\(owners[0]) and \(owners[1]) have linked to your \(haveDesc)"
            default:
                str = "\(owners[0]), \(owners[1]) and \(owners.count-2) others have linked to your \(haveDesc)"
            }

            // Show Toast
            guard let d = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
            d.window?.rootViewController?.view.makeToast(str, duration: 2.0, position: .top) {_ in }
        }
    }

    private func notifyObservers() {
        for obs in reobservers where obs is LinkedWatchersCountChangeDetectable {
            (obs as! LinkedWatchersCountChangeDetectable).havesLinkedWatchersCountChanged()
        }
    }

    private func getHaves() {
        let managedContext = CoreDataGod.managedContext
        let fetchRequest: NSFetchRequest<Have> = Have.fetchRequest()
        do {
            let u = try managedContext.fetch(fetchRequest)

            haves = u.filter { return $0.owner == CoreDataGod.user.handle }
        } catch _ as NSError {
          print("ERROR: LinkedWatchersObserver couldn't find Haves")
        }
    }
}
