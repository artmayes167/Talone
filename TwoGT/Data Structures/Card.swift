//
//  Card.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

enum CardSection: String, CaseIterable {
    case address, phone, notes
}

enum Addresses: String, CaseIterable {
    case email, home, work, box
}

enum Phone: String, CaseIterable {
    case home, cell, work, fax
}

enum Note: String, CaseIterable {
    case cardOwner, user
}

//func getKeys(for section: CardSection) -> [String] {
//    switch section {
//    case .address:
//        return Addresses.allCases.compactMap { $0.rawValue }
//    case .phone:
//        return Phone.allCases.compactMap { $0.rawValue }
//    case .notes:
//        return Note.allCases.compactMap { $0.rawValue }
//    }
// }



struct Card {
    // Store sections as dictionaries, and include all dictionaries (empty or not) in payload
    // An empty dictionary signals that a section is not included
    // If User doesn't include a section in their card, we send an empty (or null?) dict
    // If User once sent a card to someone, we could enable deletion of their contact information by replacing the previous card with empty dictionaries (to replace the data on their end), and deleting the card reference on the back end afterward
    
    var sections: [CardSection: [String: String]] = [:]
   // var creep = false
    // set up a keychain store for on-device encryption of personal data
}
