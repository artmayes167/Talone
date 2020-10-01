//
//  CardReceiverObserver.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/30/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//

import Foundation

class CardReceiverObserver {

    var fetcher: CardsObserver = CardsFetcher()    // For testing: Override with a class that conforms to CardsObserver

    func startObserving() {
        observeCardReceptions()
    }

    func observeCardReceptions() {
//        CardsFetcher().observeCardsSentToMe { [self] fibCardItems in
        fetcher.observeCardsSentToMe { (fibCardItems: [CardsBase.FiBCardItem]) in
            print("cards received! \(fibCardItems)")
            let interactions: [Interaction] = AppDelegate.user.interactions
            var newCards = [CardsBase.FiBCardItem]()
            var modifiedCards = newCards

            // cross-reference Cards

            checkNew: for fibCard in fibCardItems {
                for interaction in interactions where fibCard.id == interaction.receivedCard?.uid {
                    // card modified?
                    modifiedCards.append(fibCard)
                    continue checkNew
                }
                newCards.append(fibCard)
                // Create card in CD
            }

            // Search for any card that has been deleted.
            checkDeleted: for interaction in interactions {
                for fibCard in fibCardItems where fibCard.id == interaction.receivedCard?.uid {
                    continue checkDeleted
                }
                //interaction.receivedCard.deleteCard()
            }
        }
    }

    private func notifyUserOfNewCards(_ fibCards: [CardsBase.FiBCardItem]) {
        guard fibCards.count > 0 else { return }

        let numbers = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        var str = ""

        switch fibCards.count {
        case 1:
            str = "\(fibCards[0].owner) sent you a new card."
        case 2:
            str = "\(fibCards[0].owner) and \(fibCards[1].owner) sent you their cards."
        default:
            let s = fibCards.count-2 < 8 ? numbers[fibCards.count-2] : "\(fibCards.count-2)" // "nine", "ten", "11", "12",...
            str = "\(fibCards[0].owner), \(fibCards[1].owner) and \(s) others sent you their cards."
        }
        // Show Toast
        //self.view.makeToast(str, duration: 2.0, position: .top) {_ in
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
