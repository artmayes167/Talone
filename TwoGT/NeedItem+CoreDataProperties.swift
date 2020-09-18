//
//  NeedItem+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension NeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NeedItem> {
        return NSFetchRequest<NeedItem>(entityName: "NeedItem")
    }

    @NSManaged public var need: Need?

}
