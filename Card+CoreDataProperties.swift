//
//  Card+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/28/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var userHandle: String?
    @NSManaged public var comments: String?
    @NSManaged public var personalNotes: String?

    @NSManaged var addresses: [CardAddress]
    @NSManaged var emails: [CardEmail]
    @NSManaged var phoneNumbers: [CardPhoneNumber]
}

extension Card : Identifiable {

}
