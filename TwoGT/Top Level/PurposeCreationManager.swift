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
    private var category: NeedType?
    private var cityState: CityState?
    
    // TODO: - Rethink these inits to require city and state
    private func createPurpose(type: NeedType, cityState: CityState) -> Bool {
        let pred = NSPredicate(format: "category == %@", type.rawValue)
        let p: [Purpose] = PurposeCreationManager.query(table: "Purpose", searchPredicate: pred).filter({ (purpose) -> Bool in
            let pps = purpose as Purpose
            if let cs = pps.cityState {
                return cs.city == cityState.city && cs.state == cityState.state
            } else {
                print("---------Query failed in PurposeCreationManager -> createPurpose-- No cityState existed on an existing Purpose")
            }
            return false
        })
        if p.isEmpty { print("Query failed in PurposeCreationManager -> createPurpose-- Return array was empty" ) }
        guard let newPurpose = p.first ?? Purpose.create(type: type.rawValue, cityState: cityState) else {
            print("Failed to create new purpose in PurposeCreationManager -> createPurpose")
            return false }
        self.purpose = newPurpose
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let success = appDelegate.save()
        if success {
            print("---------Successfully saved in PurposeCreationManager -> createPurpose")
        } else {
            print("---------NOT successfully saved in PurposeCreationManager -> createPurpose")
        }
        print("---------Successfully created Purpose with PurposeCreationManager")
        return true
    }
    
    func checkPrimaryNavigationParameters() -> Bool {
        guard let c = cityState, let t = category, creationType != .unknown else  {
            print("---------Missing values in PurposeCreationManager -> checkPrimaryNavigationParameters.  cityState = \(String(describing: cityState)), category = \(String(describing: category)), creationType = \(creationType.rawValue)")
            return false
        }
        let success = createPurpose(type: t, cityState: c)
        return success
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
        print("---------Results from query = \(results)")
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
    
    func currentCreationTypeString() -> String {
        switch creationType {
        case .have:
            return "have"
        case .need:
            return "need"
        default:
            return "none"
        }
    }
    
    func currentCreationType() -> CurrentCreationType {
        return creationType
    }
    
    func setCategory(_ type: NeedType) {
        category = type
        
    }
    
    func getCategory() -> NeedType? {
        return category
    }
    
    func setLocation(cityState: CityState) {
        self.cityState = cityState
    }
    
    func setLocation(location: AppLocationInfo, communityName: String) -> Bool {
        guard let city = location.city, let state = location.state, let country = location.country else { return false }
        let c = CityState.create(city: city, state: state, country: country, communityName: communityName)
        cityState = c
        return true
    }
    
    func setLocation(city: String, state: String, country: String, community: String) {
        let c = CityState.create(city: city, state: state, country: country, communityName: community)
        self.cityState = c
    }
    
    func setCommunity(_ community: String) {
        guard let c = purpose.cityState else { return }
        let comm = Community.create(communityName: community)
        c.addToCommunities(comm)
    }
    
    func getLocationOrNil() -> CityState? {
        return cityState
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
    
    func setParentNeed(_ need: Need) {
        self.need?.addToParentNeed(need)
    }
    
    func setNeedParentHave(_ have: Have) {
        self.need?.parentHave = have
    }
    
    func setHaveParentHave(_ have: Have) {
        self.have?.parentHave = have
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
    
    func prepareForSave() -> Bool {
        switch creationType {
        case .have:
            guard let h = have else { print("Have Not Set when preparing for save!!!!"); return false }
            purpose.addToHaves(h)
            print("---------Preparing purpose for save, successfully: \(purpose.haves!.contains(h))")
            return true
        case .need:
            guard let n = need else { print("---------Need Not Set when preparing for save!!!!"); return false }
            purpose.addToNeeds(n)
            print("---------Preparing purpose for save, successfully: \(purpose.needs!.contains(n))")
            return true
        default:
            print("---------Creation Type Not Set when preparing for save!!!!")
            return false
        }
    }
    
    func getSavedPurpose() -> Purpose? {
        if !prepareForSave() { return nil }
        return purpose
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
