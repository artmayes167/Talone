//
//  Purpose+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Purpose {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purpose> {
        return NSFetchRequest<Purpose>(entityName: "Purpose")
    }

    @NSManaged public var category: String?
    @NSManaged public var cityState: CityState?
    @NSManaged public var needs: NSSet?
    @NSManaged public var haves: NSSet?
    @NSManaged public var events: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for needs
extension Purpose {

    @objc(addNeedsObject:)
    @NSManaged public func addToNeeds(_ value: Need)

    @objc(removeNeedsObject:)
    @NSManaged public func removeFromNeeds(_ value: Need)

    @objc(addNeeds:)
    @NSManaged public func addToNeeds(_ values: NSSet)

    @objc(removeNeeds:)
    @NSManaged public func removeFromNeeds(_ values: NSSet)

}

// MARK: Generated accessors for haves
extension Purpose {

    @objc(addHavesObject:)
    @NSManaged public func addToHaves(_ value: Have)

    @objc(removeHavesObject:)
    @NSManaged public func removeFromHaves(_ value: Have)

    @objc(addHaves:)
    @NSManaged public func addToHaves(_ values: NSSet)

    @objc(removeHaves:)
    @NSManaged public func removeFromHaves(_ values: NSSet)

}

// MARK: Generated accessors for events
extension Purpose {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension Purpose : Identifiable {

}
