//
//  AppLocationInfo+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension AppLocationInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppLocationInfo> {
        return NSFetchRequest<AppLocationInfo>(entityName: "AppLocationInfo")
    }

    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var country: String?

}

extension AppLocationInfo : Identifiable {

}
