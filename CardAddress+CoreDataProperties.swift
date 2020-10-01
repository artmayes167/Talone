//
//  CardAddress+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CardAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardAddress> {
        return NSFetchRequest<CardAddress>(entityName: "CardAddress")
    }

    @NSManaged public var templateTitle: String?

}
