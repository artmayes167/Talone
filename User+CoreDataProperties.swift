//
//  User+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/2/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var handle: String?
    @NSManaged public var uid: String?
    @NSManaged public var images: NSSet?
    @NSManaged public var purposes: NSSet?

    @NSManaged public var addresses: [Address]?
    @NSManaged public var cardTemplates: [Card]?
    @NSManaged public var emails: [Email]?
    @NSManaged public var interactions: [Interaction]?
    @NSManaged public var phoneNumbers: [PhoneNumber]?
    @NSManaged public var searchLocations: [SearchLocation]?
    @NSManaged public var socialMedia: [SocialMedia]?
}

// MARK: Generated accessors for images
extension User {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: ImageInfo)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: ImageInfo)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for purposes
extension User {

    @objc(addPurposesObject:)
    @NSManaged public func addToPurposes(_ value: Purpose)

    @objc(removePurposesObject:)
    @NSManaged public func removeFromPurposes(_ value: Purpose)

    @objc(addPurposes:)
    @NSManaged public func addToPurposes(_ values: NSSet)

    @objc(removePurposes:)
    @NSManaged public func removeFromPurposes(_ values: NSSet)

}

extension User : Identifiable {

}
