//
//  CardReceiverObserver.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/30/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//

import Foundation
import UIKit

class CardReceiverObserver {

    var fetcher: CardsObserver = CardsFetcher()    // For testing: Override with a class that conforms to CardsObserver

    func startObserving() {
        observeCardReceptions()
    }
    
    // TODO: - Jyrki will look at GateKeeper().decodeCodableInstance(data: Data) -> CardTemplateInstance and GateKeeper().buildCodableInstanceAndEncode(instance: CardTemplateInstance) -> Data

    func observeCardReceptions() {
        
//        CardsFetcher().observeCardsSentToMe { [self] fibCardItems in
        fetcher.observeCardsSentToMe { (fibCardItems: [CardsBase.FiBCardItem]) in
//            print("cards received! \(fibCardItems)")
//            let interactions: [Interaction] = AppDelegate.user.interactions
//            var newCards = [CardsBase.FiBCardItem]()
//            var modifiedCards = newCards
//
//            // cross-reference Cards
//
//            checkNew: for fibCard in fibCardItems {
//                for interaction in interactions where fibCard.id == interaction.receivedCard?.uid {
//                    // card modified?
//                    modifiedCards.append(fibCard)
//                    continue checkNew
//                }
//                newCards.append(fibCard)
//                // Create card in CD
//            }
//
//            // Search for any card that has been deleted.
//            checkDeleted: for interaction in interactions {
//                for fibCard in fibCardItems where fibCard.id == interaction.receivedCard?.uid {
//                    continue checkDeleted
//                }
//                //interaction.receivedCard.deleteCard()
//            }
//            self.notifyUserOfNewAndModifiedCards(newCards, modifiedCards)
            
            // New stuff
            for fibCard in fibCardItems {
                let decodedData = Data(base64Encoded: fibCard.payload)!
                _ = GateKeeper().decodeCodableInstance(data:decodedData)
            }
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
                let vc = appDelegate.window!.rootViewController
                vc?.view.makeToast("new contact information received from \(fibCardItems.count) contacts")
            }
            
        }
    }

    // I think this is overkill, but will keep in case that changes
    private func notifyUserOfNewAndModifiedCards(_ newCards: [CardsBase.FiBCardItem], _ modifiedCards: [CardsBase.FiBCardItem]) {
        guard newCards.count > 0 || modifiedCards.count > 0 else { return }

        let numbers = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        var str = ""

        switch newCards.count {
        case 0:
            switch modifiedCards.count {
            case 1:
                str = "\(modifiedCards[0].owner) modified his/her card."
            case 2:
                str = "\(modifiedCards[0].owner) & \(modifiedCards[1].owner) modified their cards."
            default:
                let s = modifiedCards.count-2 < 11 ? numbers[modifiedCards.count-2] : "\(modifiedCards.count-2)" // "nine", "ten", "11", "12",...
                str = "\(modifiedCards[0].owner), \(modifiedCards[1].owner) and \(s) other users modified their cards."
            }
        case 1:
            switch modifiedCards.count {
            case 0:
                str = "\(newCards[0].owner) sent you a new card."
            case 1:
                str = "\(newCards[0].owner) sent you a new card, \(modifiedCards[0].owner) modified his/her card."
            case 2:
                str = "\(newCards[0].owner) sent you a new card, \(modifiedCards[0].owner) & \(modifiedCards[1].owner) modified their cards."
            default:
                let s = modifiedCards.count-2 < 11 ? numbers[modifiedCards.count-2] : "\(modifiedCards.count-2)" // "nine", "ten", "11", "12",...
                str = "\(newCards[0].owner) sent you a new card, \(s) users modified their cards."
            }
        case 2:
            switch modifiedCards.count {
            case 0:
                str = "\(newCards[0].owner) and \(newCards[1].owner) sent you their cards."
            case 1:
                str = "\(newCards[0].owner) and \(newCards[1].owner) sent you their cards, \(modifiedCards[0].owner) modified his/her card."
            default:
                let s = modifiedCards.count-2 < 11 ? numbers[modifiedCards.count-2] : "\(modifiedCards.count-2)" // "nine", "ten", "11", "12",...
                str = "\(newCards[0].owner) and \(newCards[1].owner) sent you their cards, \(s) users modified their cards."
            }
        default:
            let s = newCards.count-2 < 11 ? numbers[newCards.count-2] : "\(newCards.count-2)" // "nine", "ten", "11", "12",...
            let s2 = modifiedCards.count < 11 ? numbers[modifiedCards.count] : "\(modifiedCards.count)" // "nine", "ten", "11", "12",...

            switch modifiedCards.count {
            case 0:
                str = "\(newCards[0].owner), \(newCards[1].owner) and \(s) others sent you their cards."
            case 1:
                str = "\(modifiedCards[0].owner) modified his/her card, \(newCards[0].owner), \(newCards[1].owner) and \(s) others sent you their cards."
            default:
                str = "\(newCards[0].owner), \(newCards[1].owner) and \(s) others sent you their cards. \(s2) users modified their cards."
            }
        }
        // Show Toast
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let vc = appDelegate.window?.rootViewController
        let duration = newCards.count + modifiedCards.count >= 3 ? 3.0 : 2.0 // increase toast time if lot's of text to show.
        vc?.view.makeToast(str, duration: duration, position: .top) {_ in
            print("Toast done!")
        }
    }
}

/*
 HavesDbFetcher().observeMyHaves { [self] fibHaveItems in

     var addedNeedOwners = [String]()
     var changedHaves = [HaveItem]()
     var isRedrawRequired = false

     // Cross-reference needs
     for have in self.haves {
         for fibHave in fibHaveItems where fibHave.id == have.haveItem?.id {
             if let needStubs = fibHave.needs, let haveItem = have.haveItem {
                 var isChanged = false
                 changedHaves.append(haveItem)   // for showing on UI

                 let cdNeeds = have.childNeeds

                 // First determine if there are any new needStubs that are missing from CD
                 // These are the people that have linked with this have.
                 for needStub in needStubs {
                     var found = false
                     for cdNeed in cdNeeds where cdNeed.needItem?.id == needStub.id {
                         found = true
                         break
                     }
                     if found == false {
                         // create a new need (gets appended to childItems implicitly)
                         var fibNeed = NeedsBase.NeedItem(category: fibHave.category, validUntil: fibHave.validUntil!, owner: needStub.owner, createdBy: needStub.createdBy, locationInfo: fibHave.locationInfo).self
                         fibNeed.id = needStub.id // overwrite the implicit Id to reflect existing id.
                         let n = Need.createNeed(item: NeedItem.createNeedItem(item: fibNeed))
                         n.parentHaveItemId = fibHave.id
                         addedNeedOwners.append(fibNeed.owner)
                         isChanged = true
                     }
                 }

                 // Then determine if there are needStubs being deleted requiring cleanup from CD.
                 // These are the people that have removed the link with this have.
                 for cdNeed in cdNeeds {
                     var found = false
                     for needStub in needStubs where needStub.id == cdNeed.needItem?.id {
                         found = true
                         break
                     }
                     if found == false {
                         cdNeed.deleteNeed()
                         isChanged = true
                     }
                 }
                 if isChanged { haveItem.update(); isRedrawRequired = true } // store changes to CD
             }
         }
     }
     if isRedrawRequired { collectionView.reloadData() }
     notifyUserOfNewLinks(addedNeedOwners, changedHaves)
 }
}

 */
