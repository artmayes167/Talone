/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object for the table view.
*/

import Foundation
import CoreData

/// The data model used to populate the table view on appearance
struct CardTemplateModel {
    
    private var card: Card? {
        didSet {
            configure()
        }
    }
    private var editing: Bool {
        get {
            return card != nil
        }
    }
    
    mutating func set(card: Card?) {
        self.card = card
    }
    
     // MARK: - PRIVATE PARTS (look away)
    // Only use these for new creation
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
    
    
    private mutating func configure() {
        /// If we are editing
        if let c = card {
            /// Filtering for allPossibles
            /// Card Items from card
            let a = c.addresses
            let p = c.phoneNumbers
            let e = c.emails
            allAdded = a + p + e
            
            var adds = addresses
            var phones = phoneNumbers
            var ems = emails
            /// filter out any non-Card-unique items that are already included
            for add in a {
                adds = adds.filter { $0.title != add.title }
            }
            for phone in p {
                phones = phones.filter { $0.title != phone.title }
            }
            for email in e {
                ems = ems.filter { $0.title != email.title }
            }
            
            allPossibles = adds + phones + ems
            
        } else {
            var arr: [NSManagedObject] = []
            let a = addresses
            let p = phoneNumbers
            let e = emails
            allPossibles = a + p + e
            allAdded = []
        }
    }
    
    /// Call before updating `tableView` in `performDropWith`
    mutating func addItem(at indexPath: IndexPath) {
        moveItem(to: indexPath)
    }
}
