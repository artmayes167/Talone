//
//  PhoneNumber+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension PhoneNumber {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneNumber> {
        return NSFetchRequest<PhoneNumber>(entityName: "PhoneNumber")
    }

    @NSManaged public var title: String?
    @NSManaged public var number: String?
    @NSManaged public var address: Address?

}

extension PhoneNumber : Identifiable {

}
