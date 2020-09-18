//
//  SocialMedia+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension SocialMedia {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SocialMedia> {
        return NSFetchRequest<SocialMedia>(entityName: "SocialMedia")
    }

    @NSManaged public var siteName: String?
    @NSManaged public var siteURLString: String?
    @NSManaged public var personalURLString: String?
    @NSManaged public var userName: String?
    @NSManaged public var user: User?

}

extension SocialMedia : Identifiable {

}
