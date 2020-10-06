//
//  CoreDataObjectExtensions.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

extension User {
    func sortedAddresses(clean: Bool) -> [String: [SearchLocation]] {
        var dict: [String: [SearchLocation]] = [:]
        if let locs = searchLocations {
            var home: [SearchLocation] = []
            var alternate: [SearchLocation] = []
            for s in locs {
                if s.type == "home" { home.append(s) } else if s.type == "alternate" { alternate.append(s) }
                if clean {
                    if s.type == "none" { CoreDataGod.managedContext.delete(s)}
                }
            }
            if !home.isEmpty { dict["home"] = home }
            if !alternate.isEmpty { dict["alternate"] = alternate }
        }
        return dict
    }
}

/**
 `CardTemplate` is a template with the data that will be shared, identified by `id`(uid + templateTitle)
 
 Discussion of variables:
 `uid`: The uid created by FiB (FireBase) for User on account creation.  Any reference to `uid` must refer only to the thisUser.
 `handle`: The unique identifier used by CoreData to differentiate between thisUser and otherUser

 */
extension CardTemplate {
    /**
        Only thisUser created cards
     - Parameter image: perfectly fine for this to be nil
     - Parameter title: This is a unique identifier for the card, set by You.  Namespace collision will result in replacement of the `CardTemplate`
     */
    
    class func create(cardCategory title: String, image: Data?) -> CardTemplate {
        var card: CardTemplate?
        if let temps = CoreDataGod.user.cardTemplates, !temps.isEmpty {
            let z = temps.filter({ $0.templateTitle == title })
            if !(z.isEmpty) {
                card = z.first
            }
        }
        if card == nil {
            let entity = NSEntityDescription.entity(forEntityName: "CardTemplate", in: CoreDataGod.managedContext)!
            card = CardTemplate(entity: entity, insertInto: CoreDataGod.managedContext)
            card!.templateTitle = title.lowercased()
            card!.uid = AppDelegateHelper.user.uid
            card!.userHandle = AppDelegateHelper.user.handle
        }
        
        card!.image = image

        try? CoreDataGod.managedContext.save()
        return card!
    }
    
    func allAddresses() -> [NSManagedObject] {
        var a: [NSManagedObject] = []
        a.append(contentsOf: addresses?.allObjects as! [Address])
        a.append(contentsOf: phoneNumbers?.allObjects as! [PhoneNumber])
        a.append(contentsOf: emails?.allObjects as! [Email])
        return a
    }
}

/**
        An instance of a `CardTemplate` that contains the data defined in *one of the templates*, personalized with comments.  Only call to create new
 */
extension CardTemplateInstance {
    /** - Parameter card: if set, will attempt to create from `card`.  Else, `codableCard` must be set. `card` takes precedence.
        - Parameter codableCard:  if set, in the absence of `card`, will attempt to create from `codableCard`.  Else, `card` must be set
     */
    class func create(toHandle: String, card c: CardTemplate, message: String = "", personalNotes: String = "") -> CardTemplateInstance {

        let e = NSEntityDescription.entity(forEntityName: "CardTemplateInstance", in: CoreDataGod.managedContext)!
        let instance = CardTemplateInstance(entity: e, insertInto: CoreDataGod.managedContext)
        
        instance.message = message
        instance.receiverUserHandle = toHandle
        instance.personalNotes = personalNotes
        
        instance.image = c.image
        instance.uid = c.uid
        instance.userHandle = c.userHandle
        instance.templateTitle = c.templateTitle
        
        instance.message = message
        instance.addresses = c.addresses
        instance.emails = c.emails
        instance.phoneNumbers = c.phoneNumbers
        
        try? CoreDataGod.managedContext.save()
        return instance
    }
    
    class func create(codableCard c: CodableCardTemplateInstance) -> CardTemplateInstance {
        let e = NSEntityDescription.entity(forEntityName: "CardTemplateInstance", in: CoreDataGod.managedContext)!
        let instance = CardTemplateInstance(entity: e, insertInto: CoreDataGod.managedContext)
        instance.image = c.image
        instance.uid = c.uid
        instance.userHandle = c.userHandle
        instance.receiverUserHandle = c.receiverUserHandle
        instance.templateTitle = c.templateTitle
        instance.message = c.message
        instance.addresses = NSSet(array: Address.addressesFrom(array: c.addresses))
        instance.emails = NSSet(array: Email.emailsFrom(array: c.emails))
        instance.phoneNumbers = NSSet(array: PhoneNumber.phoneNumbersFrom(array: c.phoneNumbers))
        return instance
    }
}

/// Additional required items for payload indicators
/// createdAt, modifiedAt, createdBy (uid), createdFor (uid), senderHandle
/// Exists solely to Encode for payload
struct CodableCardTemplateInstance: Codable {
    
    let receiverUserHandle: String // to -- if received, this will be AppDelegateHelper.user.handle
    
    let uid: String
    let image: Data?
    let userHandle: String // sender's user handle
    let message: String?
    let templateTitle: String
    
    let addresses: [[String: String]]
    let emails: [[String: String]]
    let phoneNumbers: [[String: String]]
    
    enum CodingKeys: String, CodingKey {
        case receiverUserHandle
        case uid, image, userHandle, message, templateTitle
        case addresses, emails, phoneNumbers
    }
    
    init(instance: CardTemplateInstance) {
        receiverUserHandle = instance.receiverUserHandle
        uid = instance.uid
        image = instance.image
        userHandle = instance.userHandle
        message = instance.message
        templateTitle = instance.templateTitle
        
        var addressBook: [[String: String]] = []
        if let adds = instance.addresses {
            for a in adds {
                if let add = a as? Address {
                    addressBook.append(add.dictionaryValue())
                }
            }
        }
        addresses = addressBook
        
        var phoneBook: [[String: String]] = []
        if let phones = instance.phoneNumbers {
            for p in phones {
                if let ph = p as? PhoneNumber {
                    phoneBook.append(ph.dictionaryValue())
                }
            }
        }
        phoneNumbers = phoneBook
        
        var emailBook: [[String: String]] = [] 
        if let emails = instance.emails {
            for e in emails {
                if let email = e as? Email {
                    emailBook.append(email.dictionaryValue())
                }
            }
        }
        emails = emailBook
    }
}

extension Community {
    class func create(communityName: String) -> Community {

        let entity = NSEntityDescription.entity(forEntityName: "Community", in: CoreDataGod.managedContext)!
        let community = Community(entity: entity, insertInto: CoreDataGod.managedContext)

        community.name = communityName

        try? CoreDataGod.managedContext.save()
        return community
    }
}

extension Email {
    class func create(name: String, emailAddress: String, uid: String?) -> Email {
        let entity = NSEntityDescription.entity(forEntityName: "Email", in: CoreDataGod.managedContext)!
        let email = Email(entity: entity, insertInto: CoreDataGod.managedContext)
        
        email.title = name.lowercased()
        email.emailString = emailAddress
        email.uid = uid ?? AppDelegateHelper.user.uid

        try? CoreDataGod.managedContext.save()
        return email
    }
    
    func dictionaryValue() -> [String: String] {
        var dict: [String: String] = [:]
        dict["title"] = title
        dict["emailString"] = emailString
        dict["uid"] = uid // from owner
        return dict
    }
    
    class func emailsFrom(array: [[String: String]]) -> [Email] {
        var arr: [Email] = []
        for dict in array {
            let e = Email.create(name: dict["title"]!, emailAddress: dict["emailString"]!, uid: dict["uid"])
            arr.append(e)
        }
        return arr
    }
}

extension SearchLocation {
    class func createSearchLocation(city: String, state: String, country: String = "USA", community: String = "", type: String) -> SearchLocation {

        let entity = NSEntityDescription.entity(forEntityName: "SearchLocation", in: CoreDataGod.managedContext)!
        let searchLocation = SearchLocation(entity: entity, insertInto: CoreDataGod.managedContext)
        
        searchLocation.city = city
        searchLocation.state = state
        searchLocation.country = country
        searchLocation.community = community
        searchLocation.type = type
        // don't save yet
        return searchLocation
    }

    func displayName() -> String {
        return city.capitalized + ", " + state.capitalized
    }
}

extension Address {  // :)
    
    /// Only called by thisUser to create
    class func create(title: String, street1: String, street2: String?, city: String, zip: String?, state: String, country: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Address", in: CoreDataGod.managedContext)!
        let add = Address(entity: entity, insertInto: CoreDataGod.managedContext)
        add.title = title
        add.street1 = street1
        add.street2 = street2
        add.city = city
        add.state = state
        add.country = country
        add.uid = AppDelegateHelper.user.uid
        add.zip = zip
        
        try? CoreDataGod.managedContext.save()
    }
    
    
    func displayName() -> String {
        return String(format: "\(street1) \n\(city), \(state)")
    }
    
    /// To someone else
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
    
    /// From someone else
    class func addressesFrom(array: [[String: String]]) -> [Address] {
        var arr: [Address] = []
        for dict in array {
            let entity = NSEntityDescription.entity(forEntityName: "Address", in: CoreDataGod.managedContext)!
            let add = Address(entity: entity, insertInto: CoreDataGod.managedContext)
            add.title = dict["title"]!
            add.street1 = dict["street1"]!
            add.street2 = dict["street2"]
            add.city = dict["city"]!
            add.state = dict["state"]!
            add.country = dict["country"]!
            add.uid = dict["uid"]!
            add.zip = dict["zip"]
            arr.append(add)
        }
        _ = try? CoreDataGod.managedContext.save()
        return arr
    }
}

extension PhoneNumber {
    class func create(title: String, number: String, uid: String?) -> PhoneNumber {
        let entity = NSEntityDescription.entity(forEntityName: "PhoneNumber", in: CoreDataGod.managedContext)!
        let phoneNum = PhoneNumber(entity: entity, insertInto: CoreDataGod.managedContext)
        
        phoneNum.title = title
        phoneNum.number = number
        phoneNum.uid = uid ?? AppDelegateHelper.user.uid
        
        try? CoreDataGod.managedContext.save()
        return phoneNum
    }
    
    /// Template title not included
    func dictionaryValue() -> [String: String] {
        var dict: [String: String] = [:]
        dict["title"] = title
        dict["number"] = number
        dict["uid"] = uid // from owner
        return dict
    }
    
    class func phoneNumbersFrom(array: [[String: String]]) -> [PhoneNumber] {
        var arr: [PhoneNumber] = []
        for p in array {
            let p = PhoneNumber.create(title: p["title"]!, number: p["number"]!, uid: p["uid"]!)
            arr.append(p)
        }
        return arr
    }
}

extension Need {
    class func createNeed(item: NeedsBase.NeedItem) -> Need {

        let entity = NSEntityDescription.entity(forEntityName: "Need", in: CoreDataGod.managedContext)!
        let needItem = Need(entity: entity, insertInto: CoreDataGod.managedContext)
        
        needItem.headline = item.headline
        needItem.category = item.category
        needItem.desc = item.description
        needItem.validUntil = item.validUntil.dateValue()
        needItem.owner = item.owner
        needItem.createdBy = item.createdBy
        needItem.createdAt = item.createdAt?.dateValue()
        needItem.modifiedAt = item.modifiedAt?.dateValue()
        needItem.id = item.id!
        
        try? CoreDataGod.managedContext.save()
        return needItem
    }

    func deleteNeed() {
        CoreDataGod.managedContext.delete(self)
        try? CoreDataGod.managedContext.save()
    }

}

extension Have {
    class func createHave(item: HavesBase.HaveItem) -> Have {

        let entity = NSEntityDescription.entity(forEntityName: "Have", in: CoreDataGod.managedContext)!
        let haveItem = Have(entity: entity, insertInto: CoreDataGod.managedContext)
        
        haveItem.headline = item.headline
        haveItem.category = item.category
        haveItem.desc = item.description
        haveItem.validUntil = item.validUntil?.dateValue()
        haveItem.owner = item.owner
        haveItem.createdBy = item.createdBy
        haveItem.createdAt = item.createdAt?.dateValue()
        haveItem.modifiedAt = item.modifiedAt?.dateValue()
        haveItem.id = item.id! 
        
        try? CoreDataGod.managedContext.save()
        return haveItem
    }

    func deleteHave() {
        CoreDataGod.managedContext.delete(self)
        try? CoreDataGod.managedContext.save()
    }

}

extension AppLocationInfo {
    class func create(city: String, state: String, country: String) -> AppLocationInfo {
        let entity = NSEntityDescription.entity(forEntityName: "AppLocationInfo", in: CoreDataGod.managedContext)!
        let locationInfo = AppLocationInfo(entity: entity, insertInto: CoreDataGod.managedContext)

        locationInfo.country = country
        locationInfo.city = city
        locationInfo.state = state

        try? CoreDataGod.managedContext.save()
        return locationInfo
    }
}

extension Contact {
    /// Setting the `newPersonHandle` enables CoreData to find this `Interaction`, and `templateName` is a marker to allow the user to change which template is associated with which other userHandle
    class func create(newPersonHandle handle: String, newPersonUid uid: String) -> Contact {

        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: CoreDataGod.managedContext)!
        let contact = Contact(entity: entity, insertInto: CoreDataGod.managedContext)

        contact.contactUid = uid
        contact.contactHandle = handle

        try? CoreDataGod.managedContext.save()
        return contact
    }
}
