//
//  CoreDataObjectExtensions.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

extension Purpose {
    
    class func create(type: String, city: String, state: String, country: String = "USA", community: String = "") -> Purpose {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Purpose",
                                     in: managedContext)!
        
       let purpose = Purpose(entity: entity, insertInto: managedContext)
        purpose.setValue(type, forKey: "category")
        let c = CityState.create(city: city, state: state, country: country, communityName: community)
        purpose.setValue(c, forKey: "cityState")
        
        do {
          try managedContext.save()
            return purpose
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    func cdKey() -> String? {
        return cityState?.displayName()
    }
}

extension CityState {
    class func create(city: String, state: String, country: String, communityName: String) -> CityState {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "CityState",
                                     in: managedContext)!
        
        let cityState = CityState(entity: entity, insertInto: managedContext) as CityState
        
        let community = Community.create(communityName: communityName)
        
        cityState.country = country
        cityState.city = city
        cityState.state = state
        cityState.addToCommunities(community)
        
        do {
          try managedContext.save()
            return cityState
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    func displayName() -> String {
        if let c = city, let s = state {
            return c.capitalized + ", " + s.capitalized
        } else { fatalError() }
    }
    
    func locationInfo() -> AppLocationInfo {
        let a = AppLocationInfo.create(city: city!, state: state!, country: country!)
        return a
    }
}

extension Community {
    class func create(communityName: String) -> Community {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Community",
                                     in: managedContext)!
        
       guard let community = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Community else {
                                                fatalError()
        }
        
        community.name = communityName
        
        do {
          try managedContext.save()
            return community
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension User {
    func sortedAddresses() -> Dictionary<String, [SearchLocation]> {
        var dict: Dictionary<String, [SearchLocation]> = [:]
        if let locs = searchLocations {
            var home: [SearchLocation] = []
            var alternate: [SearchLocation] = []
            for s in locs {
                if (s as? SearchLocation)?.type == "home" { home.append(s as! SearchLocation) }
                else if (s as? SearchLocation)?.type == "alternate" { alternate.append(s as! SearchLocation) }
            }
            dict["home"] = home
            dict["alternate"] = alternate
        }
        return dict
    }
}

extension Email {
    class func create(name: String, emailAddress: String) -> Email {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Email",
                                     in: managedContext)!
        
       guard let email = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Email else {
                                                fatalError()
        }
        
        email.name = name
        email.emailString = emailAddress
        
        do {
          try managedContext.save()
            return email
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension Item {
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        guard let c = category, !c.isEmpty else { return false }
        if light { return true }
        else {
            return !(desc?.isEmpty ?? true) && !(headline?.isEmpty ?? true)
        }
    }
}

extension SearchLocation {
    class func createSearchLocation(city: String, state: String, country: String = "USA", community: String = "") -> SearchLocation {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SearchLocation",
                                     in: managedContext)!
        
       guard let searchLocation = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? SearchLocation else {
                                                fatalError()
        }
        searchLocation.city = city
        searchLocation.state = state
        searchLocation.country = country
        searchLocation.community = community
        do {
          try managedContext.save()
            return searchLocation
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    func displayName() -> String {
        if let c = city, let s = state {
            return c.capitalized + ", " + s.capitalized
        } else { fatalError() }
    }
}

extension Address {
    class func createAddress(city: String, state: String, country: String = "USA", type: String = "home") -> Address {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Address",
                                     in: managedContext)!
        
       guard let address = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Address else {
                                                fatalError()
        }
        address.type = type
        do {
          try managedContext.save()
            return address
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    func locationInfoOrNil() -> AppLocationInfo? {
        if let _ = city, let _ = state, let _ = country {
            return self
        }
        return nil
    }
}

extension NeedItem {
    class func createNeedItem(item: NeedsBase.NeedItem) -> NeedItem {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "NeedItem",
                                     in: managedContext)!
        
       guard let needItem = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? NeedItem else {
                                                fatalError()
        }
        needItem.category = item.category
        needItem.desc = item.description
        needItem.validUntil = item.validUntil.dateValue()
        needItem.owner = item.owner
        needItem.createdBy = item.createdBy
        needItem.createdAt = item.createdAt?.dateValue()
        needItem.id = item.id
        do {
          try managedContext.save()
            return needItem
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension Need {
    class func createNeed(item: NeedItem) -> Need {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Need",
                                     in: managedContext)!
        
       guard let need = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Need else {
                                                fatalError()
        }
        need.needItem = item
        do {
          try managedContext.save()
            return need
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension HaveItem {
    class func createHaveItem(item: HavesBase.HaveItem) -> HaveItem {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "HaveItem",
                                     in: managedContext)!
        
       guard let haveItem = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? HaveItem else {
                                                fatalError()
        }
        haveItem.category = item.category
        haveItem.desc = item.description
        haveItem.validUntil = item.validUntil?.dateValue()
        haveItem.owner = item.owner
        haveItem.createdBy = item.createdBy
        haveItem.createdAt = item.createdAt?.dateValue()
        haveItem.id = item.id
        do {
          try managedContext.save()
            return haveItem
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension Have {
    class func createHave(item: HaveItem) -> Have {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Have",
                                     in: managedContext)!
        
       guard let have = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Have else {
                                                fatalError()
        }
        have.haveItem = item
        do {
          try managedContext.save()
            return have
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension AppLocationInfo {
    class func create(city: String, state: String, country: String) -> AppLocationInfo {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "AppLocationInfo",
                                     in: managedContext)!
        
        let locationInfo = AppLocationInfo(entity: entity, insertInto: managedContext)
        
        locationInfo.country = country
        locationInfo.city = city
        locationInfo.state = state
        
        do {
          try managedContext.save()
            return locationInfo
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}
