//
//  Item+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdBy: String?
    @NSManaged public var desc: String?
    @NSManaged public var headline: String?
    @NSManaged public var id: String?
    @NSManaged public var modifiedAt: Date?
    @NSManaged public var owner: String?
    @NSManaged public var validUntil: Date?
    @NSManaged public var location: SearchLocation?
    @NSManaged public var watchers: NSSet?

}

// MARK: Generated accessors for watchers
extension Item {

    @objc(addWatchersObject:)
    @NSManaged public func addToWatchers(_ value: UserStub)

    @objc(removeWatchersObject:)
    @NSManaged public func removeFromWatchers(_ value: UserStub)

    @objc(addWatchers:)
    @NSManaged public func addToWatchers(_ values: NSSet)

    @objc(removeWatchers:)
    @NSManaged public func removeFromWatchers(_ values: NSSet)

}

extension Item : Identifiable {

}
