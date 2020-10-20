//
//  CoreDataImageHelper.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/29/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class CoreDataImageHelper: NSObject {
    static let shared = CoreDataImageHelper()
    
    func saveImage(_ image: UIImage, fileName: String?, url: String = "") {
        ImageInfo.create(withHandle: nil, image: image, named: fileName, url: url)
    }
    
    func deleteAllImages() {
        let images = Array(CoreDataGod.user.images ?? [])
        if !images.isEmpty {
            for image in images {
                CoreDataGod.managedContext.delete(image)
            }
        }
    }
    
    func fetchAllImages() -> [ImageInfo]? {
        return CoreDataGod.user.images
    }
}
