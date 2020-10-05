//
//  Have+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Have {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Have> {
        return NSFetchRequest<Have>(entityName: "Have")
    }

    @NSManaged public var parentHaveItemId: String?
    @NSManaged public var personalNotes: String?

    @NSManaged public var childHaves: [Have]?
    @NSManaged public var childNeeds: [Need]?
}
