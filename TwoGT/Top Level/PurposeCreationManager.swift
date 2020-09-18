//
//  PurposeCreationManager.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

enum CurrentCreationType: Int {
    case need, have, unknown
}

class PurposeCreationManager: NSObject {
    
    private var purpose: Purpose = Purpose()
    private var need: Need?
    private var have: Have?
    private var creationType: CurrentCreationType = .unknown
    
    
    // TODO: - Rethink these inits to require city and state
    convenience init?(type: NeedType, city: String, state: String, country: String = "USA", community: String = "") {
        self.init()
        let pred = NSPredicate(format: "category == %@", type.rawValue)
        let p: [Purpose] = PurposeCreationManager.query(table: "Purpose", searchPredicate: pred).filter({ (purpose) -> Bool in
            let pps = purpose as Purpose
            if let cs = pps.cityState {
                return cs.city == city && cs.state == state
            }
            return false
        })
        self.purpose = p.first ?? Purpose.create(type: type.rawValue, city: city, state: state)
        print("Successfully created Purpose with PurposeCreationManager.query")
        
    }
    
    /*
     let name = "John Appleseed"

     let newContact = addRecord(Contact.self)
     newContact.contactNo = 1
     newContact.contactName = name

     let contacts = query(Contact.self, search: NSPredicate(format: "contactName == %@", name))
     for contact in contacts
     {
         print ("Contact name = \(contact.contactName), no = \(contact.contactNo)")
     }

     deleteRecords(Contact.self, search: NSPredicate(format: "contactName == %@", name))

     recs = recordsInTable(Contact.self)
     print ("Contacts table has \(recs) records")

     saveDatabase()
     */
    
    // Attempt at generic creation
    class func query<T: NSManagedObject>(table: String, searchPredicate: NSPredicate) -> [T] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: table)
        fetchRequest.predicate = searchPredicate
        let results = try! context.fetch(fetchRequest)
        return results
    }
    
//    class func createPurpose(inContext managedContext: NSManagedObjectContext, cityState: CityState, type: NeedType) -> Purpose {
//
//        let entity =
//          NSEntityDescription.entity(forEntityName: "Purpose",
//                                     in: managedContext)!
//
//       guard let purpose = NSManagedObject(entity: entity,
//                                              insertInto: managedContext) as? Purpose else {
//                                                fatalError()
//        }
//        purpose.category = type.rawValue
//        purpose
//        do {
//          try managedContext.save()
//            return purpose
//        } catch let error as NSError {
//          print("Could not save. \(error), \(error.userInfo)")
//            fatalError()
//        }
//    }
    
    func setCreationType(_ type: CurrentCreationType) {
        creationType = type
    }
    
    func currentCreationType() -> String {
        switch creationType {
        case .have:
            return "have"
        case .need:
            return "need"
        default:
            return "none"
        }
    }
    
    func setCategory(_ type: NeedType) {
        purpose.category = type.rawValue
    }
    
    func getCategory() -> NeedType {
        return NeedType(rawValue: purpose.category!)! // crash if not
    }
    
    func setLocation(cityState: CityState) {
        purpose.cityState = cityState
    }
    
    func setLocation(location: AppLocationInfo) {
        guard let c = purpose.cityState else { fatalError() }
        c.city = location.city
        c.state = location.state
        c.country = location.country
    }
    
    func setLocation(city: String, state: String, country: String) {
        guard let c = purpose.cityState else { fatalError() }
        c.city = city
        c.state = state
        c.country = country
    }
    
    func setCommunity(_ community: String) {
        guard let c = purpose.cityState else { return }
        let comm = Community.create(communityName: community)
        c.addToCommunities(comm)
    }
    
    func getLocationOrNil() -> CityState? {
        return purpose.cityState
    }
    
    func setHeadline(_ headline: String?, description: String?) {
        switch creationType {
        case .have:
            guard let h = have?.haveItem else { return }
            h.headline = headline
            h.desc = description
        case .need:
            guard let n = need?.needItem else { return }
            n.headline = headline
            n.desc = description
        default:
            return
        }
    }
    
    func getHeadline() -> String? {
        switch creationType {
        case .have:
            return have?.haveItem?.headline
        case .need:
            return need?.needItem?.headline
        default:
            return nil
        }
    }
    
    func getDescription() -> String? {
        switch creationType {
        case .have:
            return have?.haveItem?.desc
        case .need:
            return need?.needItem?.desc
        default:
            return nil
        }
    }
    
    func setNeed(_ need: Need) {
        self.need = need
    }
    
    func setNeedItem(item: NeedItem) {
        guard let n = need else {
            need = Need.createNeed(item: item)
            return
        }
        n.needItem = item
    }
    
    func setHave(_ have: Have) {
        self.have = have
    }
    
    func setHaveItem(item: HaveItem) {
        guard let h = have else {
            have = Have.createHave(item: item)
            return
        }
        h.haveItem = item
    }
    
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        switch creationType {
        case .have:
            return have?.haveItem?.areAllRequiredFieldsFilled(light: light) ?? false
        case .need:
            return need?.needItem?.areAllRequiredFieldsFilled(light: light) ?? false
        default:
            return false
        }
    }
    
}

//extension PurposeCreationManager {
//
//    func addRecord<T: NSManagedObject>(_ type : T.Type) -> T
//    {
//        let entityName = T.description()
//        let context = app.managedObjectContext
//        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
//        let record = T(entity: entity!, insertInto: context)
//        return record
//    }
//
//    func recordsInTable<T: NSManagedObject>(_ type : T.Type) -> Int
//    {
//        let recs = allRecords(T.self)
//        return recs.count
//    }
//
//
//    func allRecords<T: NSManagedObject>(_ type : T.Type, sort: NSSortDescriptor? = nil) -> [T]
//    {
//        let context = app.managedObjectContext
//        let request = T.fetchRequest()
//        do
//        {
//            let results = try context.fetch(request)
//            return results as! [T]
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//            return []
//        }
//    }
//
//    func query<T: NSManagedObject>(_ type : T.Type, search: NSPredicate?, sort: NSSortDescriptor? = nil, multiSort: [NSSortDescriptor]? = nil) -> [T]
//    {
//        let context = app.managedObjectContext
//        let request = T.fetchRequest()
//        if let predicate = search
//        {
//            request.predicate = predicate
//        }
//        if let sortDescriptors = multiSort
//        {
//            request.sortDescriptors = sortDescriptors
//        }
//        else if let sortDescriptor = sort
//        {
//            request.sortDescriptors = [sortDescriptor]
//        }
//
//        do
//        {
//            let results = try context.fetch(request)
//            return results as! [T]
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//            return []
//        }
//
//    }
//
//
//    func deleteRecord(_ object: NSManagedObject)
//    {
//        let context = app.managedObjectContext
//        context.delete(object)
//    }
//
//    func deleteRecords<T: NSManagedObject>(_ type : T.Type, search: NSPredicate? = nil)
//    {
//        let context = app.managedObjectContext
//
//        let results = query(T.self, search: search)
//        for record in results
//        {
//            context.delete(record)
//        }
//    }
//
//    func saveDatabase()
//    {
//        let context = app.managedObjectContext
//
//        do
//        {
//            try context.save()
//        }
//        catch
//        {
//            print("Error saving database: \(error)")
//        }
//    }
//}
