/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object for the table view.
*/

import Foundation
import CoreData

/// The data model used to populate the table view on app launch.
struct CardTemplateModel {
    var addresses: [Address] {
        get {
            let adds =  AppDelegate.user.addresses
            return adds.sorted { return $0.type! < $1.type! }
        }
    }
    
    var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegate.user.phoneNumbers
            return phones.sorted { return $0.title! < $1.title! }
        }
    }
    
    var emails: [Email] {
        get {
            let ems =  AppDelegate.user.emails
            return ems.sorted { return $0.name! < $1.name! }
        }
    }
    
    // MARK: - Array Management
   var allPossibles: [NSManagedObject]?
   var allAdded: [NSManagedObject]?
    
   mutating func configure() {
       var arr: [NSManagedObject] = []
       let allArrays: [[NSManagedObject]] = [addresses, phoneNumbers, emails]
       for array in allArrays {
           for x in array {
               arr.append(x)
           }
       }
       allPossibles = arr
       allAdded = []
   }
    
    private var movingObject: NSManagedObject?
    var sourceIndexPath: IndexPath?
    
    mutating func moveStarted(with object: NSManagedObject, indexPath: IndexPath) {
        movingObject = object
        sourceIndexPath = indexPath
    }
    
    /// The traditional method for rearranging rows in a table view.
    mutating func moveItem(to destinationIndexPath: IndexPath) {
        guard sourceIndexPath!.section != destinationIndexPath.section else { return }
        guard var sourceArray = sourceIndexPath!.section == 0 ? allAdded : allPossibles,
              var destinationArray = destinationIndexPath.section == 0 ? allAdded : allPossibles else { fatalError() }
        
        sourceArray.remove(at: sourceIndexPath!.row)
        destinationArray.append(movingObject!) //insert(movingObject!, at: destinationIndexPath.row)
        
        switch sourceIndexPath!.section {
        case 0:
            allAdded = sourceArray
            allPossibles = destinationArray
        case 1:
            allAdded = destinationArray
            allPossibles = sourceArray
        default:
            fatalError()
        }
    }
    
    /// The method for adding a new item to the table view's data model.
    mutating func addItem(at indexPath: IndexPath) {
        moveItem(to: indexPath)
    }
}
