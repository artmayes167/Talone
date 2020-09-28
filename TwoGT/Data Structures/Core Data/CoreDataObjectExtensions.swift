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

    class func create(type: String, cityState: CityState) -> Purpose {
        print("Started Purpose -> create")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Purpose",
                                     in: managedContext)!

       let purpose = Purpose(entity: entity, insertInto: managedContext)
        purpose.setValue(type, forKeyPath: "category")
        
        let cs: NSManagedObject = CityState.create(city: cityState.city!, state: cityState.state!, country: cityState.country!, communityName: "")
        
        purpose.setValue(cs as? CityState, forKeyPath: "cityState")
        print("---------This is what the purpose looks like after adding values in Purpose extension------- \(purpose)")
        do {
          try managedContext.save()
            print("Successfully created Purpose in Purpose extension!")
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

        let cityState: CityState = CityState(entity: entity, insertInto: managedContext) as CityState

        let community = Community.create(communityName: communityName)

        cityState.setValue(country, forKeyPath: "country")
        cityState.setValue(city, forKeyPath: "city")
        cityState.setValue(state, forKeyPath: "state")
        cityState.setValue(country, forKeyPath: "country")
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

        community.setValue(communityName, forKeyPath: "name")

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
    func sortedAddresses() -> [String: [SearchLocation]] {
        var dict: [String: [SearchLocation]] = [:]
        if let locs = searchLocations {
            var home: [SearchLocation] = []
            var alternate: [SearchLocation] = []
            for s in locs {
                if (s as? SearchLocation)?.type == "home" { home.append(s as! SearchLocation) } else if (s as? SearchLocation)?.type == "alternate" { alternate.append(s as! SearchLocation) }
            }
            if !home.isEmpty { dict["home"] = home }
            if !alternate.isEmpty { dict["alternate"] = alternate }
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
        email.uid = UserDefaults.standard.string(forKey: "uid")

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
        if light { return true } else {
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
        searchLocation.setValue(city, forKeyPath: "city")
        searchLocation.setValue(state, forKeyPath: "state")
        searchLocation.setValue(country, forKeyPath: "country")
        searchLocation.setValue(community, forKeyPath: "community")
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
    func displayName() -> String {
        return String(format: "\(street1!) \n\(city!), \(state!)")
    }
//    class func createAddress(city: String, state: String, country: String = "USA", type: String = "home") -> Address {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let entity = NSEntityDescription.entity(forEntityName: "Address",
//                                     in: managedContext)!
//
//       guard let address = NSManagedObject(entity: entity,
//                                              insertInto: managedContext) as? Address else {
//                                                fatalError()
//        }
//        address.setValue(type, forKeyPath: "type")
//        do {
//          try managedContext.save()
//            return address
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//            fatalError()
//        }
//    }

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
        needItem.setValue(item.category, forKeyPath: "category")
        needItem.setValue(item.description, forKeyPath: "desc")
        needItem.setValue(item.validUntil.dateValue(), forKeyPath: "validUntil")
        needItem.setValue(item.owner, forKeyPath: "owner")
        needItem.setValue(item.createdBy, forKeyPath: "createdBy")
        needItem.setValue(item.createdAt?.dateValue(), forKeyPath: "createdAt")
        needItem.setValue(item.modifiedAt?.dateValue(), forKeyPath: "modifiedAt")
        needItem.setValue(item.id, forKeyPath: "id")
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
        need.setValue(item, forKey: "needItem")
        do {
          try managedContext.save()
            return need
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }

    func deleteNeed() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(self)
        try? managedContext.save()
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
        haveItem.setValue(item.category, forKeyPath: "category")
        haveItem.setValue(item.description, forKeyPath: "desc")
        haveItem.setValue(item.validUntil?.dateValue(), forKeyPath: "validUntil")
        haveItem.setValue(item.owner, forKeyPath: "owner")
        haveItem.setValue(item.createdBy, forKeyPath: "createdBy")
        haveItem.setValue(item.createdAt?.dateValue(), forKeyPath: "createdAt")
        haveItem.setValue(item.modifiedAt?.dateValue(), forKeyPath: "modifiedAt")
        haveItem.setValue(item.id, forKeyPath: "id")
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
        have.setValue(item, forKeyPath: "haveItem")
        do {
          try managedContext.save()
            return have
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }

    func deleteHave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(self)
        try? managedContext.save()
    }

}

extension AppLocationInfo {
    class func create(city: String, state: String, country: String) -> AppLocationInfo {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "AppLocationInfo",
                                     in: managedContext)!

        let locationInfo = AppLocationInfo(entity: entity, insertInto: managedContext)

        locationInfo.setValue(country, forKeyPath: "country")
        locationInfo.setValue(city, forKeyPath: "city")
        locationInfo.setValue(state, forKeyPath: "state")

        do {
          try managedContext.save()
            return locationInfo
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}
