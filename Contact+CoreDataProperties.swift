//
//  Contact+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var contactHandle: String?
    @NSManaged public var contactUid: String?
    @NSManaged public var receivedCards: [CardTemplateInstance]?
    @NSManaged public var sentCards: [CardTemplateInstance]?
    @NSManaged public var rating: [ContactRating]?
}

extension Contact : Identifiable {

}
