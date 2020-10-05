//
//  User+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var handle: String
    @NSManaged public var uid: String
    
    @NSManaged public var addresses: [Address]?
    @NSManaged public var cardTemplates: [CardTemplate]?
    @NSManaged public var contacts: [Contact]?
    @NSManaged public var emails: [Email]?
    @NSManaged public var haves: [Have]?
    @NSManaged public var needs: [Need]?
    @NSManaged public var images: [ImageInfo]?
    @NSManaged public var phoneNumbers: [PhoneNumber]?
    @NSManaged public var searchLocations: [SearchLocation]?
    @NSManaged public var socialMedia: [SocialMedia]?
}

extension User : Identifiable {
    public var id: String { uid }
}
