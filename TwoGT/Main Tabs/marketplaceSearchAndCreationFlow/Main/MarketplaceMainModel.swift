//
//  MarketplaceMainModel.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

/// This model manages the tableview and the tabs, via dependency injection
class MarketplaceMainModel {
    var havesArray: [HavesBase.HaveItem]?
    var needsArray: [NeedsBase.NeedItem]?
    weak var customTab: NeedHaveTabControllerView?
    
    /// for tableView numberOfRows
    var relevantCount: Int {
        guard let c = customTab else { return 0 }
        if c.left {
            return needsArray?.count ?? 0
        } else {
            return havesArray?.count ?? 0
        }
    }
    
    /// Okay, this is kind of a goof.  Whichever call returns first is the `winner`, and we select that tab, and load that table
    private var winner = true
    
    public func configure(for c: MarketplaceMainVC) {
        havesArray = []
        needsArray = []
        winner = true
        fetchNeeds(for: c)
        fetchHaves(for: c)
        customTab = c.needHaveTabController
        customTab!.tableView.reloadData()
        customTab!.tableView.alpha = 0.5
    }
    
    private func fetchNeeds(for c: MarketplaceMainVC) {
        guard let loc = c.loc else { return }
        NeedsDbFetcher().fetchNeedsFor(category: c.category.rawValue, city: loc.city, state: loc.state, country: loc.country, maxCount: 20, filterOutThisUser: true) { array, error in

            if error != nil {
                c.showOkayAlert(title: "", message: error!.localizedDescription) {_ in }
                return
            }
            self.needsArray = array
            let tab = self.customTab!
            if self.winner {
                self.winner = false
                tab.selectedLeftTab(tab.leftTabButton)
                tab.tableView.alpha = 1.0
            }
        }
    }
    
    private func fetchHaves(for c: MarketplaceMainVC) {
        guard let loc = c.loc else { return }

        let v = c.category.firebaseValue()
        if v.lowercased() == "any" {
            let msg = "There are no results for any categories in this city. If you have anything, please share"
            HavesDbFetcher().fetchAllHaves(city: loc.city, loc.state, loc.country, maxCount: 10) { array, error in
                handleResults(array, msg, error)
            }
        } else {
            let msg = "There are no results for \(v.lowercased()), in this city. If you have anything, please share"
            HavesDbFetcher().fetchHaves(matching: [v], loc.city, loc.state, loc.country) { array, error in
                handleResults(array, msg, error)
            }
        }

        func handleResults(_ array: [HavesBase.HaveItem], _ message: String, _ error: Error?) {
            self.havesArray = array.filter { $0.owner != AppDelegateHelper.user.handle }
            let tab = self.customTab!
            if self.winner {
                self.winner = false
                tab.selectedRightTab(tab.rightTabButton)
                tab.tableView.alpha = 1.0
            }
        }
    }
    
    func populateCell(cell c: MarketplaceCell, row: Int) {
        if customTab!.left {
            if let need = needsArray?[row] {
                let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == need.owner })
                c.configure(rating: contact?.rating?.first, needItem: need)
            }
        } else {
            if let have = havesArray?[row] {
                let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == have.owner })
                c.configure(rating: contact?.rating?.first, haveItem: have)
            }
        }
    }
    
    func selectedCell(at row: Int, controller c: MarketplaceMainVC) {
        if customTab!.left {
            let need = needsArray![row]
            c.performSegue(withIdentifier: "toDetails", sender: need)
        } else {
            let have = havesArray![row]
            c.performSegue(withIdentifier: "toDetails", sender: have)
        }
    }
}
