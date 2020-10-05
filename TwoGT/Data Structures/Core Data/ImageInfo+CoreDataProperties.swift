//
//  ImageInfo+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageInfo> {
        return NSFetchRequest<ImageInfo>(entityName: "ImageInfo")
    }

    @NSManaged public var image: Data?
    @NSManaged public var imageName: String?
    @NSManaged public var imageURLString: String?
    @NSManaged public var handle: String

}

extension ImageInfo : Identifiable {
    public var id: String { handle }
}
