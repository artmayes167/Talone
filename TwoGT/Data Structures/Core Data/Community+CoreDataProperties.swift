//
//  Community+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Community {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Community> {
        return NSFetchRequest<Community>(entityName: "Community")
    }

    @NSManaged public var name: String?

}

extension Community : Identifiable {

}
