//
//  Email+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Email {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Email> {
        return NSFetchRequest<Email>(entityName: "Email")
    }

    @NSManaged public var emailString: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var templates: NSSet?

}

// MARK: Generated accessors for templates
extension Email {

    @objc(addTemplatesObject:)
    @NSManaged public func addToTemplates(_ value: CardTemplate)

    @objc(removeTemplatesObject:)
    @NSManaged public func removeFromTemplates(_ value: CardTemplate)

    @objc(addTemplates:)
    @NSManaged public func addToTemplates(_ values: NSSet)

    @objc(removeTemplates:)
    @NSManaged public func removeFromTemplates(_ values: NSSet)

}

extension Email : Identifiable {

}
