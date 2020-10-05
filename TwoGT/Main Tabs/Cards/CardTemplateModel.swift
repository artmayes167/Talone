/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object for the table view.
*/

import Foundation
import CoreData

/// The data model used to populate the table view on appearance
struct CardTemplateModel {
    
    private var card: CardTemplate? {
        didSet {
            configure()
        }
    }
    private var editing: Bool {
        get {
            return card != nil
        }
    }
    
    mutating func set(card: CardTemplate?) {
        self.card = card
    }
    
     // MARK: - PRIVATE PARTS (look away)
    ///filter all possibles to remove added
    private var addresses: [Address] {
        get {
            let adds = AppDelegateHelper.user.addresses
            guard var a = adds, !(a.isEmpty) else { return [] }
            guard let c = card else { return a }
            a = a.filter { !($0.templates?.contains(c) ?? false) }
            return a.sorted { return $0.title < $1.title }
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegateHelper.user.phoneNumbers
            guard var p = phones, !(p.isEmpty) else { return [] }
            guard let c = card else { return p }
            p = p.filter { !($0.templates?.contains(c) ?? false) }
            return  p.sorted { return $0.title < $1.title }
        }
    }
    
    private var emails: [Email] {
        get {
            let ems =  AppDelegateHelper.user.emails
            guard var e = ems, !(e.isEmpty) else { return [] }
            guard let c = card else { return e }
            e = e.filter { !($0.templates?.contains(c) ?? false) }
            return e.sorted { return $0.title < $1.title }
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
                    }
                }
            }
            if let phones = c.phoneNumbers {
                for p in phones {
                    if let ph = p as? PhoneNumber {
                        allAdded.append(ph)
                    }
                }
            }
            if let emails = c.emails {
                for e in emails {
                    if let email = e as? Email {
                        allAdded.append(email)
                    }
                }
            }
        }
    }
    
    /// Call before updating `tableView` in `performDropWith`
    mutating func addItem(at indexPath: IndexPath) {
        moveItem(to: indexPath)
    }
}
