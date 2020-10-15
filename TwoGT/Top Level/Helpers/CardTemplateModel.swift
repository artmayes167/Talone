/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object for the table view.
*/

import Foundation
import CoreData

/// The data model used to populate the table view on appearance
struct CardTemplateModel {
    
    private var card: CardTemplateInstance? {
        didSet {
            configure()
        }
    }
    private var editing: Bool = true
    
    mutating func set(card: CardTemplateInstance) {
        self.card = card
    }
    
     // MARK: - PRIVATE PARTS (look away)
    ///filter all possibles to remove added
    private var addresses: [Address] {
        get {
            var adds: [Address] = []
            
            let u: [Address] = CoreDataGod.user.addresses ?? []
            if !u.isEmpty {
                guard let c = card else { return u }
                let applicableAddresses = u.filter { !($0.templates?.contains(c) ?? false) }
                adds = applicableAddresses.sorted { return $0.title! < $1.title! }
            }
            return adds
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            var phones: [PhoneNumber] = []
            
            let u: [PhoneNumber] = CoreDataGod.user.phoneNumbers ?? []
            if !u.isEmpty {
                guard let c = card else { return u }
                let applicablePhones = u.filter { !($0.templates?.contains(c) ?? false) }
                phones = applicablePhones.sorted { return $0.title! < $1.title! }
            }
            return phones
        }
    }
    
    private var emails: [Email] {
        get {
            var emails: [Email] = []
            
            let u: [Email] = CoreDataGod.user.emails ?? []
            if !u.isEmpty {
                guard let c = card else { return u }
                let applicableEmails = u.filter { !($0.templates?.contains(c) ?? false) }
                emails = applicableEmails.sorted { return $0.title! < $1.title! }
            }
            return emails
        }
    }
    
    /// set by `moveStarted`
    private var movingObject: NSManagedObject?
    
    /// - Private: The traditional method for rearranging rows in a table view, heavily modified
    private mutating func moveItem(to destinationIndexPath: IndexPath) {
        guard sourceIndexPath!.section != destinationIndexPath.section else { return }
        var sourceArray = sourceIndexPath!.section == 0 ? allAdded : allPossibles
        var destinationArray = destinationIndexPath.section == 0 ? allAdded : allPossibles
        
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
   var allPossibles: [NSManagedObject] = []
    /// Will contain all `addresses`, `emails`, and `phoneNumbers` user adds by dragging
   var allAdded: [NSManagedObject] = []
    /// set by `moveStarted`
    var sourceIndexPath: IndexPath?
    
    
    private mutating func configure() {
        
        allPossibles = addresses + phoneNumbers + emails
        if let c = card {
            if let adds = c.addresses {
                for a in adds {
                    if let add = a as? Address {
                        allAdded.append(add)
                        allPossibles.removeAll(where: { ($0 as? Address)?.title == add.title })
                    }
                }
            }
            if let phones = c.phoneNumbers {
                for p in phones {
                    if let ph = p as? PhoneNumber {
                        allAdded.append(ph)
                        allPossibles.removeAll(where: { ($0 as? PhoneNumber)?.title == ph.title })
                    }
                }
            }
            if let emails = c.emails {
                for e in emails {
                    if let email = e as? Email {
                        allAdded.append(email)
                        allPossibles.removeAll(where: { ($0 as? Email)?.title == email.title })
                    }
                }
            }
        } else {
            allPossibles = addresses + phoneNumbers + emails
        }
    }
    
    /// Call before updating `tableView` in `performDropWith`
    mutating func addItem(at indexPath: IndexPath) {
        moveItem(to: indexPath)
    }
}
