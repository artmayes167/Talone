//
//  SocialMedia+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension SocialMedia {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SocialMedia> {
        return NSFetchRequest<SocialMedia>(entityName: "SocialMedia")
    }

    @NSManaged public var personalURLString: String?
    @NSManaged public var siteName: String
    @NSManaged public var siteURLString: String?
    @NSManaged public var userName: String
    @NSManaged public var uid: String
    @NSManaged public var templates: NSSet?

}

// MARK: Generated accessors for templates
extension SocialMedia {

    @objc(addTemplatesObject:)
    @NSManaged public func addToTemplates(_ value: CardTemplate)

    @objc(removeTemplatesObject:)
    @NSManaged public func removeFromTemplates(_ value: CardTemplate)

    @objc(addTemplates:)
    @NSManaged public func addToTemplates(_ values: NSSet)

    @objc(removeTemplates:)
    @NSManaged public func removeFromTemplates(_ values: NSSet)

}

extension SocialMedia : Identifiable {

}
