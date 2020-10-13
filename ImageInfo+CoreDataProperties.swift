//
//  ImageInfo+CoreDataProperties.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
//

import UIKit
import CoreData


extension ImageInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageInfo> {
        return NSFetchRequest<ImageInfo>(entityName: "ImageInfo")
    }

    @NSManaged public var handle: String?
    @NSManaged public var image: UIImage?
    @NSManaged public var imageName: String?
    @NSManaged public var imageURLString: String?

}

extension ImageInfo : Identifiable {

}
