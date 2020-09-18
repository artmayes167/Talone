//
//  User+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
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
    @NSManaged public var emails: NSSet?
    @NSManaged public var socialMediaInfo: NSSet?
    @NSManaged public var purposes: NSSet?
    @NSManaged public var addresses: NSSet?
    @NSManaged public var images: NSSet?
    @NSManaged public var cards: NSSet?
    @NSManaged public var searchLocations: NSSet?
    @NSManaged public var phoneNumbers: NSSet?

}

// MARK: Generated accessors for emails
extension User {

    @objc(addEmailsObject:)
    @NSManaged public func addToEmails(_ value: Email)

    @objc(removeEmailsObject:)
    @NSManaged public func removeFromEmails(_ value: Email)

    @objc(addEmails:)
    @NSManaged public func addToEmails(_ values: NSSet)

    @objc(removeEmails:)
    @NSManaged public func removeFromEmails(_ values: NSSet)

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

// MARK: Generated accessors for addresses
extension User {

    @objc(addAddressesObject:)
    @NSManaged public func addToAddresses(_ value: Address)

    @objc(removeAddressesObject:)
    @NSManaged public func removeFromAddresses(_ value: Address)

    @objc(addAddresses:)
    @NSManaged public func addToAddresses(_ values: NSSet)

    @objc(removeAddresses:)
    @NSManaged public func removeFromAddresses(_ values: NSSet)

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

// MARK: Generated accessors for cards
extension User {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

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

// MARK: Generated accessors for phoneNumbers
extension User {

    @objc(addPhoneNumbersObject:)
    @NSManaged public func addToPhoneNumbers(_ value: PhoneNumber)

    @objc(removePhoneNumbersObject:)
    @NSManaged public func removeFromPhoneNumbers(_ value: PhoneNumber)

    @objc(addPhoneNumbers:)
    @NSManaged public func addToPhoneNumbers(_ values: NSSet)

    @objc(removePhoneNumbers:)
    @NSManaged public func removeFromPhoneNumbers(_ values: NSSet)

}

extension User : Identifiable {

}
