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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImage(data: Data) {
        let imageInfo = ImageInfo(context: context)
        imageInfo.image = data
        imageInfo.type = "userImage"
        AppDelegate.user.addToImages(imageInfo)
        do {
            try context.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage() -> ImageInfo? {
        var fetchingImage = [ImageInfo]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageInfo")
        do {
            fetchingImage = try context.fetch(fetchRequest) as! [ImageInfo]
        } catch {
            print("Error while fetching the image")
        }
        return fetchingImage.first(where: { $0.type == "userImage" })
    }
}
