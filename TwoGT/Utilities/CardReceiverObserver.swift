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

    func observeCardReceptions() {

        fetcher.observeCardsSentToMe { (fibCardItems: [CardsBase.FiBCardItem]) in
            print("cards received! \(fibCardItems)")
            let interactions: [Interaction] = AppDelegate.user.interactions
            var newCards = [CardsBase.FiBCardItem]()
            var modifiedCards = newCards

            // cross-reference Cards
            checkNew: for fibCard in fibCardItems {
                // Check if we have an existing interaction and this is a card update.
                for interaction in interactions where fibCard.owner == interaction.referenceUserHandle {
                    // card modified? has modifiedAt changed? if so, modify, otherwise ignore
                    modifiedCards.append(fibCard)
                    continue checkNew
                }
                newCards.append(fibCard)
                if let decodedData = Data(base64Encoded: fibCard.payload) {
                    // Create card in CD
                    _ = GateKeeper().decodeCodableInstance(data: decodedData)
                } else {
                    print("WARNING: \(#function): Payload data can't be decoded!!")
                }
            }

            // Search for any card that has been deleted by the remove owner of that card.
            checkDeleted: for interaction in interactions {
                for fibCard in fibCardItems where fibCard.owner == interaction.referenceUserHandle {
                    continue checkDeleted
                }
                //interaction.receivedCard.deleteCard()
            }
            self.notifyUserOfNewAndModifiedCards(newCards, modifiedCards)
        }
    }

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
