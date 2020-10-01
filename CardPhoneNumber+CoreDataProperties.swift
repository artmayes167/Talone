//
//  CardPhoneNumber+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CardPhoneNumber {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardPhoneNumber> {
        return NSFetchRequest<CardPhoneNumber>(entityName: "CardPhoneNumber")
    }

    @NSManaged public var templateTitle: String?

}
