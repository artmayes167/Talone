//
//  Card+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var userHandle: String?
    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var uid: String?

    @NSManaged var addresses: [Address]
    @NSManaged var emails: [Email]
    @NSManaged var phoneNumbers: [PhoneNumber]
}

extension Card : Identifiable {

}
