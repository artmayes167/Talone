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
    static let shareInstance = CoreDataImageHelper()
    
    func saveImage(data: Data) {
        
        let imageInfo = ImageInfo(context: CoreDataGod.managedContext)
        imageInfo.image = data
        imageInfo.handle = CoreDataGod.user.handle
        try? CoreDataGod.managedContext.save()
    }
    
    func fetchAllImages() -> [ImageInfo]? {
        return CoreDataGod.user.images
    }
}
