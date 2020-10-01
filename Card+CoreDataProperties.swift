//
//  Card+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var comments: String?
    @NSManaged public var image: Data?
    @NSManaged public var personalNotes: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var userHandle: String?

    @NSManaged public var addresses: [CardAddress]
    @NSManaged public var emails: [CardEmail]
    @NSManaged public var phoneNumbers: [CardPhoneNumber]
}

extension Card : Identifiable {

}
