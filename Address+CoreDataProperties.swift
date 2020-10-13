//
//  Address+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var street1: String?
    @NSManaged public var street2: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var zip: String?
    @NSManaged public var templates: NSSet?

}

// MARK: Generated accessors for templates
extension Address {

    @objc(addTemplatesObject:)
    @NSManaged public func addToTemplates(_ value: CardTemplate)

    @objc(removeTemplatesObject:)
    @NSManaged public func removeFromTemplates(_ value: CardTemplate)

    @objc(addTemplates:)
    @NSManaged public func addToTemplates(_ values: NSSet)

    @objc(removeTemplates:)
    @NSManaged public func removeFromTemplates(_ values: NSSet)

}
