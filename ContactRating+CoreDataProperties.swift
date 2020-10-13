//
//  ContactRating+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactRating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactRating> {
        return NSFetchRequest<ContactRating>(entityName: "ContactRating")
    }

    @NSManaged public var bad: Int64
    @NSManaged public var contactHandle: String?
    @NSManaged public var good: Int64
    @NSManaged public var justSo: Int64

}

extension ContactRating : Identifiable {

}
