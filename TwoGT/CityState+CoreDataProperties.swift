//
//  CityState+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension CityState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityState> {
        return NSFetchRequest<CityState>(entityName: "CityState")
    }

    @NSManaged public var purpose: Purpose?
    @NSManaged public var communities: NSSet?

}

// MARK: Generated accessors for communities
extension CityState {

    @objc(addCommunitiesObject:)
    @NSManaged public func addToCommunities(_ value: Community)

    @objc(removeCommunitiesObject:)
    @NSManaged public func removeFromCommunities(_ value: Community)

    @objc(addCommunities:)
    @NSManaged public func addToCommunities(_ values: NSSet)

    @objc(removeCommunities:)
    @NSManaged public func removeFromCommunities(_ values: NSSet)

}
