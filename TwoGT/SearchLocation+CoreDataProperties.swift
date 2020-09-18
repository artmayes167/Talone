//
//  SearchLocation+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension SearchLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchLocation> {
        return NSFetchRequest<SearchLocation>(entityName: "SearchLocation")
    }

    @NSManaged public var community: String?
    @NSManaged public var type: String?
    @NSManaged public var user: User?

}
