//
//  Need+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Need {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Need> {
        return NSFetchRequest<Need>(entityName: "Need")
    }

    @NSManaged public var personalNotes: String?
    @NSManaged public var purpose: Purpose?
    @NSManaged public var childNeeds: Need?
    @NSManaged public var parentNeed: NSSet?
    @NSManaged public var parentHave: Have?
    @NSManaged public var needItem: NeedItem?

}

// MARK: Generated accessors for parentNeed
extension Need {

    @objc(addParentNeedObject:)
    @NSManaged public func addToParentNeed(_ value: Need)

    @objc(removeParentNeedObject:)
    @NSManaged public func removeFromParentNeed(_ value: Need)

    @objc(addParentNeed:)
    @NSManaged public func addToParentNeed(_ values: NSSet)

    @objc(removeParentNeed:)
    @NSManaged public func removeFromParentNeed(_ values: NSSet)

}

extension Need : Identifiable {

}
