//
//  AppLocationInfo+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension AppLocationInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppLocationInfo> {
        return NSFetchRequest<AppLocationInfo>(entityName: "AppLocationInfo")
    }

    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var state: String

}

extension AppLocationInfo : Identifiable {
}
