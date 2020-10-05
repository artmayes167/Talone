//
//  CardTemplateInstance+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CardTemplateInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardTemplateInstance> {
        return NSFetchRequest<CardTemplateInstance>(entityName: "CardTemplateInstance")
    }

    @NSManaged public var receiverUserHandle: String
    @NSManaged public var personalNotes: String?
    @NSManaged public var message: String?

}
