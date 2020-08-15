//
//  Card.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

struct Card {
    // Store sections as dictionaries, and include all dictionaries (empty or not) in payload
    // An empty dictionary signals that a section is not included
    // If User doesn't include a section in their card, we send an empty (or null?) dict
    // If User once sent a card to someone, we could enable deletion of their contact information by replacing the previous card with empty dictionaries (to replace the data on their end), and deleting the card reference on the back end afterward
}
