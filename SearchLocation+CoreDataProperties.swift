//
//  SearchLocation+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension SearchLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchLocation> {
        return NSFetchRequest<SearchLocation>(entityName: "SearchLocation")
    }

    @NSManaged public var community: String?
    @NSManaged public var type: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension SearchLocation {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
