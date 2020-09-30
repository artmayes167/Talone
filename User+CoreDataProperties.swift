//
//  User+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
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
    @NSManaged public var searchLocations: NSSet?
    @NSManaged public var socialMediaInfo: NSSet?
    
    @NSManaged var addresses: [Address]
    @NSManaged var emails: [Email]
    @NSManaged var phoneNumbers: [PhoneNumber]
    @NSManaged var interactions: [Interaction]
    @NSManaged var cardTemplates: [Card]

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

// MARK: Generated accessors for searchLocations
extension User {

    @objc(addSearchLocationsObject:)
    @NSManaged public func addToSearchLocations(_ value: SearchLocation)

    @objc(removeSearchLocationsObject:)
    @NSManaged public func removeFromSearchLocations(_ value: SearchLocation)

    @objc(addSearchLocations:)
    @NSManaged public func addToSearchLocations(_ values: NSSet)

    @objc(removeSearchLocations:)
    @NSManaged public func removeFromSearchLocations(_ values: NSSet)

}

// MARK: Generated accessors for socialMediaInfo
extension User {

    @objc(addSocialMediaInfoObject:)
    @NSManaged public func addToSocialMediaInfo(_ value: SocialMedia)

    @objc(removeSocialMediaInfoObject:)
    @NSManaged public func removeFromSocialMediaInfo(_ value: SocialMedia)

    @objc(addSocialMediaInfo:)
    @NSManaged public func addToSocialMediaInfo(_ values: NSSet)

    @objc(removeSocialMediaInfo:)
    @NSManaged public func removeFromSocialMediaInfo(_ values: NSSet)

}

extension User : Identifiable {

}
