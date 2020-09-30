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

extension Card {
    class func create(image: Data?, title: String, uid: String, handle: String, comments: String?, notes: String?) -> Card {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Card",
                                     in: managedContext)!

       guard let card = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? Card else {
                                                fatalError()
        }
        card.image = image
        card.title = title
        card.uid = uid
        card.userHandle = handle
        card.comments = comments
        card.personalNotes = notes

        do {
          try managedContext.save()
            return card
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

extension CardTemplateInstance {
    /// - Parameter received: if `true` personal notes and template will not be stored from back end
    class func create(received: Bool, card: Card, senderHandle: String, receiverHandle: String) -> CardTemplateInstance {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "CardTemplateInstance",
                                     in: managedContext)!

       guard let instance = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? CardTemplateInstance else {
                                                fatalError()
        }
        
        instance.receiverUserHandle = receiverHandle
        instance.senderUserHandle = senderHandle
        
        instance.image = card.image
        instance.uid = card.uid  // may not be necessary
        instance.userHandle = card.userHandle
        instance.comments = card.comments
        if !received {
            instance.title = card.title
            instance.personalNotes = card.personalNotes
        }
        
        do {
          try managedContext.save()
            return instance
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}

/// Additional required items for payload indicators
/// createdAt, modifiedAt, createdBy (uid), createdFor (uid), senderHandle
/// Exists solely to Encode for payload
struct CodableCardTemplateInstance: Codable {
    
    let receiverUserHandle: String
    let senderUserHandle: String
    
    let uid: String  // may not be necessary
    let image: Data?
    let userHandle: String
    let comments: String?
    
    let addresses: [[String: String]]
    let emails: [[String: String]]
    let phoneNumbers: [[String: String]]
    
    enum CodingKeys: String, CodingKey {
        case receiverUserHandle, senderUserHandle
        case uid, image, userHandle, comments
        case addresses, emails, phoneNumbers
    }
    
    init(instance: CardTemplateInstance) {
        receiverUserHandle = instance.receiverUserHandle!
        senderUserHandle = instance.senderUserHandle!
        
        image = instance.image
        uid = instance.uid!  // may not be necessary
        userHandle = instance.userHandle!
        comments = instance.comments
        
        var addressBook: [[String: String]] = []
        for a in instance.addresses {
            addressBook.append(a.dictionaryValue())
        }
        addresses = addressBook
        
        var phoneBook: [[String: String]] = []
        for p in instance.phoneNumbers {
            phoneBook.append(p.dictionaryValue())
        }
        phoneNumbers = phoneBook
        
        var emailBook: [[String: String]] = [] 
        for e in instance.emails {
            emailBook.append(e.dictionaryValue())
        }
        emails = emailBook
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

extension CardEmail {
    class func create(title: String, email: Email) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "CardEmail",
                                     in: managedContext)!

       guard let cardEmail = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? CardEmail else {
                                                fatalError()
        }
        cardEmail.title = email.title
        cardEmail.emailString = email.emailString
        cardEmail.templateTitle = title
        cardEmail.uid = email.uid

        do {
          try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    /// Template title not included
    func dictionaryValue() -> [String: String] {
        var dict: [String: String] = [:]
        dict["title"] = title
        dict["emailString"] = emailString
        dict["uid"] = uid // from owner
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
        email.title = name
        email.emailString = emailAddress
        email.uid = UserDefaults.standard.string(forKey: DefaultsKeys.uid.rawValue)

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

extension CardAddress {
    class func create(title: String, address: Address) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "CardAddress",
                                     in: managedContext)!

       guard let cardAddress = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? CardAddress else {
                                                fatalError()
        }
        cardAddress.title = address.title  // unique
        cardAddress.templateTitle = title  // unique

        cardAddress.street1 = address.street1
        cardAddress.street2 = address.street2
        cardAddress.city = address.city
        cardAddress.state = address.state
        cardAddress.country = address.country
        cardAddress.uid = address.uid // from owner
        cardAddress.zip = address.zip

        do {
          try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    func dictionaryValue() -> [String: String] {
        var dict: [String: String] = [:]
        dict["title"] = title
        dict["street1"] = street1
        dict["street2"] = street2
        dict["city"] = city
        dict["state"] = state
        dict["country"] = country
        dict["uid"] = uid // from owner
        dict["zip"] = zip
        return dict
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

extension CardPhoneNumber {
    class func create(title: String, phoneNumber: PhoneNumber) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "CardPhoneNumber",
                                     in: managedContext)!

       guard let cardNum = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? CardPhoneNumber else {
                                                fatalError()
        }
        cardNum.title = phoneNumber.title
        cardNum.number = phoneNumber.number
        cardNum.templateTitle = title
        cardNum.uid = phoneNumber.uid

        do {
          try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
    
    /// Template title not included
    func dictionaryValue() -> [String: String] {
        var dict: [String: String] = [:]
        dict["title"] = title
        dict["number"] = number
        dict["uid"] = uid // from owner
        return dict
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
        haveItem.category = item.category
        haveItem.desc = item.description
        haveItem.validUntil = item.validUntil?.dateValue()
        haveItem.owner = item.owner
        haveItem.createdBy = item.createdBy
        haveItem.createdAt = item.createdAt?.dateValue()
        haveItem.modifiedAt = item.modifiedAt?.dateValue()
        haveItem.id = item.id
        do {
          try managedContext.save()
            return haveItem
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }

    func update() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        try? managedContext.save()
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
        // This should set the haveItem's `have` value
        have.haveItem = item
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

extension Interaction {
    /// Setting the `newPersonHandle` enables CoreData to find this `Interaction`, and `templateName` is a marker to allow the user to change which template is associated with which other userHandle
    class func create(newPersonHandle handle: String, templateName template: String?) -> Interaction {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Interaction",
                                     in: managedContext)!

        let interaction = Interaction(entity: entity, insertInto: managedContext)

        interaction.referenceUserHandle = handle
        interaction.templateName = template

        do {
          try managedContext.save()
            return interaction
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }
}
