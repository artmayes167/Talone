//
//  Community+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
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
    @NSManaged public var cityState: CityState?

}

extension Community : Identifiable {

}
