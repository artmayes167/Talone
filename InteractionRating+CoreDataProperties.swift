//
//  InteractionRating+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension InteractionRating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InteractionRating> {
        return NSFetchRequest<InteractionRating>(entityName: "InteractionRating")
    }

    @NSManaged public var bad: Int64
    @NSManaged public var good: Int64
    @NSManaged public var justSo: Int64
    @NSManaged public var referenceUserHandle: String?

}

extension InteractionRating : Identifiable {

}
