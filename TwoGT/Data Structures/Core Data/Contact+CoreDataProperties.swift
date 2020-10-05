//
//  Contact+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var contactHandle: String
    @NSManaged public var contactUid: String

    @NSManaged public var rating: [ContactRating]?
    @NSManaged public var receivedCards: [CardTemplateInstance]?
    @NSManaged public var sentCards: [CardTemplateInstance]?
}

extension Contact : Identifiable {
    public var id: String { contactUid }
}
