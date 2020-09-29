//
//  Address+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/28/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var street1: String?
    @NSManaged public var street2: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var zip: String?

}
