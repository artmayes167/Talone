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
    private var headline: String?
    private var desc: String?
    
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
        var newCityState: NSManagedObject?
        if p.isEmpty {
            print("Query failed in PurposeCreationManager -> createPurpose-- Return array was empty" )
            newCityState = CityState.create(city: cityState.city!, state: cityState.state!, country: cityState.country!)
        }
        guard let newPurpose = p.first ?? Purpose.create(type: type.rawValue, cityState: cityState) else {
            print("Failed to create new purpose in PurposeCreationManager -> createPurpose")
            return false }
        if let c = newCityState as? CityState {
            newPurpose.setValue(c, forKeyPath: "cityState")
        }
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
    
    ///This function calls createPurpose()
    /// - Returns: `true` if `cityState` and  `category` have been previously set,` false` otherwise
    func checkPrimaryNavigationParameters(save: Bool) -> Bool {
        guard let c = cityState, let t = category, creationType != .unknown else  {
            print("---------Missing values in PurposeCreationManager -> checkPrimaryNavigationParameters.  cityState = \(String(describing: cityState)), category = \(String(describing: category)), creationType = \(creationType.rawValue)")
            return false
        }
        if save {
            let success = createPurpose(type: t, cityState: c)
            return success
        }
        return true
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
        let c: NSManagedObject = CityState.create(city: cityState.city!, state: cityState.state!, country: cityState.country!)
        self.cityState = c as? CityState
    }
    
    func setLocation(location: AppLocationInfo, communityName: String) -> Bool {
        guard let city = location.city, let state = location.state, let country = location.country else { return false }
        let c: NSManagedObject = CityState.create(city: city, state: state, country: country, communityName: communityName)
        cityState = c as? CityState
        return true
    }
    
    func setLocation(city: String, state: String, country: String, community: String) {
        let c: NSManagedObject = CityState.create(city: city, state: state, country: country, communityName: community)
        cityState = c as? CityState
    }
    
    func setCommunity(_ community: String) {
        guard let c = purpose.cityState else { return }
        let comm = Community.create(communityName: community)
        c.addToCommunities(comm)
    }
    
    func getLocationOrNil() -> CityState? {
        return cityState
    }
    
    /// - Returns: `true` if able to set both headline and description,` false` otherwise
    func setHeadline(_ headline: String?, description: String?) -> Bool {
        self.headline = headline
        self.desc = description
        if let h = headline, !h.isEmpty, let d = description, !d.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func getHeadline() -> String? {
        return headline
    }
    
    func getDescription() -> String? {
        return desc
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
    
//    func setParentNeed(_ need: Need) {
//        self.need?.addToParentNeed(need)
//    }
//    
//    func setNeedParentHave(_ have: Have) {
//        self.need?.parentHave = have
//    }
//    
//    func setHaveParentHave(_ have: Have) {
//        self.have?.parentHave = have
//    }
    
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
    
    /// - Returns: `true` if the item contains all required information,` false` otherwise
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        let success = prepareForSave()
        if success {
            switch creationType {
            case .have:
                return have?.haveItem?.areAllRequiredFieldsFilled(light: light) ?? false
            case .need:
                return need?.needItem?.areAllRequiredFieldsFilled(light: light) ?? false
            default:
                return false
            }
        }
        return false
    }
    
    /// - Returns: `true` if the relevant `Have` or `Need` has been created properly,` false` otherwise
    func prepareForSave() -> Bool {
        switch creationType {
        case .need:
            guard let n = need else { print("---------Need Not Set when preparing for save!!!!"); return false }
            guard let item = n.needItem else { print("---------NeedItem Not Set when preparing for save!!!!"); return false}
            item.desc = desc
            item.headline = headline
            purpose.addToNeeds(n)
            
            print("---------Preparing purpose for save, successfully: \(purpose.needs!.contains(n))")
            return true
        case .have:
            guard let h = have else { print("Have Not Set when preparing for save!!!!"); return false }
            guard let item = h.haveItem else { print("---------HaveItem Not Set when preparing for save!!!!"); return false}
            item.desc = desc
            item.headline = headline
            purpose.addToHaves(h)
            
            print("---------Preparing purpose for save, successfully: \(purpose.haves!.contains(h))")
            return true
        default:
            print("---------Creation Type Not Set when preparing for save!!!!")
            return false
        }
    }
    
    /// - Returns: `Purpose` object , if corresponding item has been properly created,` nil` otherwise
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
