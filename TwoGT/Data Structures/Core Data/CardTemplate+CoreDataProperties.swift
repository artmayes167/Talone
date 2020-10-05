//
//  CardTemplate+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CardTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardTemplate> {
        return NSFetchRequest<CardTemplate>(entityName: "CardTemplate")
    }

    @NSManaged public var image: Data?
    @NSManaged public var templateTitle: String
    @NSManaged public var uid: String
    @NSManaged public var userHandle: String
    @NSManaged public var addresses: NSSet?
    @NSManaged public var emails: NSSet?
    @NSManaged public var phoneNumbers: NSSet?
    @NSManaged public var socialMedia: NSSet?

}

// MARK: Generated accessors for addresses
extension CardTemplate {

    @objc(addAddressesObject:)
    @NSManaged public func addToAddresses(_ value: Address)

    @objc(removeAddressesObject:)
    @NSManaged public func removeFromAddresses(_ value: Address)

    @objc(addAddresses:)
    @NSManaged public func addToAddresses(_ values: NSSet)

    @objc(removeAddresses:)
    @NSManaged public func removeFromAddresses(_ values: NSSet)

}

// MARK: Generated accessors for emails
extension CardTemplate {

    @objc(addEmailsObject:)
    @NSManaged public func addToEmails(_ value: Email)

    @objc(removeEmailsObject:)
    @NSManaged public func removeFromEmails(_ value: Email)

    @objc(addEmails:)
    @NSManaged public func addToEmails(_ values: NSSet)

    @objc(removeEmails:)
    @NSManaged public func removeFromEmails(_ values: NSSet)

}

// MARK: Generated accessors for phoneNumbers
extension CardTemplate {

    @objc(addPhoneNumbersObject:)
    @NSManaged public func addToPhoneNumbers(_ value: PhoneNumber)

    @objc(removePhoneNumbersObject:)
    @NSManaged public func removeFromPhoneNumbers(_ value: PhoneNumber)

    @objc(addPhoneNumbers:)
    @NSManaged public func addToPhoneNumbers(_ values: NSSet)

    @objc(removePhoneNumbers:)
    @NSManaged public func removeFromPhoneNumbers(_ values: NSSet)

}

// MARK: Generated accessors for socialMedia
extension CardTemplate {

    @objc(addSocialMediaObject:)
    @NSManaged public func addToSocialMedia(_ value: SocialMedia)

    @objc(removeSocialMediaObject:)
    @NSManaged public func removeFromSocialMedia(_ value: SocialMedia)

    @objc(addSocialMedia:)
    @NSManaged public func addToSocialMedia(_ values: NSSet)

    @objc(removeSocialMedia:)
    @NSManaged public func removeFromSocialMedia(_ values: NSSet)

}

extension CardTemplate : Identifiable {
    public var id: String { uid + templateTitle }
}
