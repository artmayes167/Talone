//
//  Item+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: String?
    @NSManaged public var category: String?
    @NSManaged public var desc: String?
    @NSManaged public var validUntil: Date?
    @NSManaged public var owner: String?
    @NSManaged public var createdBy: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var headline: String?

}

extension Item : Identifiable {

}
