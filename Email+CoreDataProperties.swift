//
//  Email+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/27/20.
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
    @NSManaged public var name: String?
    @NSManaged public var uid: String?

}

extension Email : Identifiable {

}
