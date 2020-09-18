//
//  HaveItem+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension HaveItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HaveItem> {
        return NSFetchRequest<HaveItem>(entityName: "HaveItem")
    }

    @NSManaged public var have: Have?

}
