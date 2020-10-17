//
//  MarketplaceMainModel.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

class MarketplaceMainModel {
    var havesArray: [HavesBase.HaveItem]?
    var needsArray: [NeedsBase.NeedItem]?
    weak var customTab: NeedHaveTabControllerView?
    
    var relevantCount: Int {
        guard let c = customTab else { return 0 }
        if c.left {
            return needsArray?.count ?? 0
        } else {
            return havesArray?.count ?? 0
        }
    }
    
    public func configure(for c: MarketplaceMainVC) {
        fetchNeeds(for: c)
        fetchHaves(for: c)
        customTab = c.needHaveTabController
    }
    
    private func fetchNeeds(for c: MarketplaceMainVC) {
        guard let loc = c.loc else { return }
        NeedsDbFetcher().fetchNeedsFor(category: c.category.rawValue, city: loc.city, state: loc.state, country: loc.country, maxCount: 20, filterOutThisUser: true) { array, error in

            if error != nil { c.showOkayAlert(title: "", message: error!.localizedDescription) {_ in } }
            self.needsArray = array
            
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
