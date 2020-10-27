//
//  UserStub+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension UserStub {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserStub> {
        return NSFetchRequest<UserStub>(entityName: "UserStub")
    }

    @NSManaged public var email: String?
    @NSManaged public var uid: String?
    @NSManaged public var userHandle: String?
    @NSManaged public var item: Item?

}

extension UserStub : Identifiable {

}
