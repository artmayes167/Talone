/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object for the table view.
*/

import Foundation
import CoreData

/// The data model used to populate the table view on appearance
struct CardTemplateModel {
    
    var card: Card?
    
     // MARK: - PRIVATE PARTS (look away)
    private var addresses: [Address] {
        get {
            let adds = AppDelegate.user.addresses
            guard let a = adds, !(a.isEmpty) else { return [] }
            let sortedAdds = a.sorted { return $0.title! < $1.title! }
            return sortedAdds.filter { $0.entity.name != CardAddress().entity.name }
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegate.user.phoneNumbers
            guard let p = phones, !(p.isEmpty) else { return [] }
            let sortedPhones = p.sorted { return $0.title! < $1.title! }
            return sortedPhones.filter { $0.entity.name != CardPhoneNumber().entity.name }
        }
    }
    
    private var emails: [Email] {
        get {
            let ems =  AppDelegate.user.emails
            guard let e = ems, !(e.isEmpty) else { return [] }
            let sortedEmails = e.sorted { return $0.title! < $1.title! }
            return sortedEmails.filter { $0.entity.name != CardEmail().entity.name }
        }
    }
    
    /// set by `moveStarted`
    private var movingObject: NSManagedObject?
    
    /// - Private: The traditional method for rearranging rows in a table view, heavily modified
    private mutating func moveItem(to destinationIndexPath: IndexPath) {
        guard sourceIndexPath!.section != destinationIndexPath.section else { return }
        guard var sourceArray = sourceIndexPath!.section == 0 ? allAdded : allPossibles,
              var destinationArray = destinationIndexPath.section == 0 ? allAdded : allPossibles else { fatalError() }
        
        sourceArray.remove(at: sourceIndexPath!.row)
        destinationArray.append(movingObject!) //insert(movingObject!, at: destinationIndexPath.row)
        
        /// This is what I get for using a struct
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
    
    /// Call when dragItem is being created
    internal mutating func moveStarted(with object: NSManagedObject, indexPath: IndexPath) {
        movingObject = object
        sourceIndexPath = indexPath
    }
    
     // MARK: - Accessors & Array Management
    /// Contains all `addresses`, `emails`, and `phoneNumbers` user has previously saved
   var allPossibles: [NSManagedObject]?
    /// Will contain all `addresses`, `emails`, and `phoneNumbers` user adds by dragging
   var allAdded: [NSManagedObject]?
    /// set by `moveStarted`
    var sourceIndexPath: IndexPath?
    
    /// Call to set the initial values we will be accessing, ideally in `viewDidLoad`
    mutating func configure() {
        
        if let c = card {
            /// Filtering for allPossibles
            /// get each stored` Address`, `CardAddress`, `PhoneNumber`, `CardPhoneNumber`, `Email`, and `CardEmail`
            /// get rid of Card versions
            var a = addresses.filter { $0.entity.name != CardAddress().entity.name }
            var p = phoneNumbers.filter { $0.entity.name != CardPhoneNumber().entity.name }
            var e = emails.filter { $0.entity.name != CardEmail().entity.name }
            
            /// filter out any non-Card-unique items that are already included
            for add in c.addresses {
                a = a.filter { $0.title != add.title }
            }
            for phone in c.phoneNumbers {
                p = p.filter { $0.title != phone.title }
            }
            for email in c.emails {
                e = e.filter { $0.title != email.title }
            }
            
            allPossibles = a + p + e
            
            allAdded = c.addresses + c.phoneNumbers + c.emails
        } else {
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
    }
    
    /// Call before updating `tableView` in `performDropWith`
    mutating func addItem(at indexPath: IndexPath) {
        moveItem(to: indexPath)
    }
}
