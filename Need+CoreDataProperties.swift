//
//  Need+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/23/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension Need {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Need> {
        return NSFetchRequest<Need>(entityName: "Need")
    }

    @NSManaged public var personalNotes: String?
    @NSManaged public var parentHaveItemId: String?
    @NSManaged public var parentNeedItemId: String?
    @NSManaged public var needItem: NeedItem?
    @NSManaged public var purpose: Purpose?

    @NSManaged var childNeeds: [Need]
    @NSManaged var parentNeed: Need
    @NSManaged var parentHave: Have
    
    /*
     managedObjectContext.refreshObject(someCard, mergeChanges: true)
     // This works and returns [Stat] type
     someCard.statsOfTypeOne
     // So does this
     someCard.valueForkey("statsOfTypeOne") as! [Stat]
     */
}

extension Need : Identifiable {

}
