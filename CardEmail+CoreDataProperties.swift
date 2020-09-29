//
//  CardEmail+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/28/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CardEmail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEmail> {
        return NSFetchRequest<CardEmail>(entityName: "CardEmail")
    }

    @NSManaged public var templateTitle: String?

}
