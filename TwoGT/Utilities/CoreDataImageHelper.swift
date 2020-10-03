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
        /// remove old image, if it exists
        if let i = fetchAllImages() {
            for x in i {
                AppDelegate.user.removeFromImages(x)
                context.delete(x)
            }
        }
        
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
        if let fetchingImage = fetchAllImages() {
            return fetchingImage.first
        }
        return nil
    }
    
    func fetchAllImages() -> [ImageInfo]? {
        var fetchingImage = [ImageInfo]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageInfo")
        do {
            fetchingImage = try context.fetch(fetchRequest) as! [ImageInfo]
            return fetchingImage.filter { $0.type == "userImage" }
        } catch {
            print("Error while fetching the image")
        }
        return nil
    }
}
