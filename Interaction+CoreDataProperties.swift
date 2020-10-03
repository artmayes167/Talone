//
//  Interaction+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Interaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Interaction> {
        return NSFetchRequest<Interaction>(entityName: "Interaction")
    }

    @NSManaged public var referenceUserHandle: String?
    @NSManaged public var templateName: String?

    @NSManaged public var rating: [InteractionRating]?
    @NSManaged public var receivedCard: [CardTemplateInstance]?
    @NSManaged public var sentCard: [CardTemplateInstance]?
}

extension Interaction : Identifiable {

}
