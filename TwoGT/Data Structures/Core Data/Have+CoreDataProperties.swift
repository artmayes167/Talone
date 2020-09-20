//
//  Have+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Have {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Have> {
        return NSFetchRequest<Have>(entityName: "Have")
    }

    @NSManaged public var personalNotes: String?
    @NSManaged public var purpose: Purpose?
    @NSManaged public var parentHave: Have?
    @NSManaged public var childHaves: NSSet?
    @NSManaged public var childNeeds: Need?
    @NSManaged public var haveItem: HaveItem?

}

// MARK: Generated accessors for childHaves
extension Have {

    @objc(addChildHavesObject:)
    @NSManaged public func addToChildHaves(_ value: Have)

    @objc(removeChildHavesObject:)
    @NSManaged public func removeFromChildHaves(_ value: Have)

    @objc(addChildHaves:)
    @NSManaged public func addToChildHaves(_ values: NSSet)

    @objc(removeChildHaves:)
    @NSManaged public func removeFromChildHaves(_ values: NSSet)

}

extension Have : Identifiable {

}
