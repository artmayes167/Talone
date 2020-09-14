//
//  PurposeProtocol.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

protocol Purpose {
    func setCategory(_ type: NeedType)
    func getCategory() -> NeedType?
    
    /// Sets object values, and saves to Defaults if `fromDefaults` is false.   If `fromDefaults` is true, object values will be set from Defaults.
    /// - Parameter fromDefaults: Boolean representing whether we have new data, or are lloading `fromDefaults`
    /// - Parameter city: Ignored, if `fromDefaults` is *true*
    /// - Parameter state: Ignored, if `fromDefaults` is *true*
    func setLocation(fromDefaults: Bool, city: String, state: String)
    
    func isLocationValid() -> Bool
    func getLocation() -> CityState
    
    /// - Returns: a `NeedsDbWriter.LocationInfo` object
    func getLocationData() -> NeedsDbWriter.LocationInfo
    func getCurrentHeadline() -> String
    func getCurrentDescription() -> String
    
    /// Checks required object values.  If `light` is true., the function will check for location values (CityState object) and category.  If `light` is false, this will also check for headline and description requirements.
    /// - Parameter light: Boolean representing whether we are creating a light `Need` to attach to a `Have`, or a full (or "heavy") `Need`
    /// - Returns: A Boolean representing whether the requirements indicated by `light` are met
    func areAllRequiredFieldsFilled(light: Bool) -> Bool
    
    /// Sets object values, if included-- object retains old value, otherwise
    /// - Parameter headline: Defaults to an empty string
    func setHeadline(_ headline: String?, description: String?)
}

extension Purpose {
    func setCategory(_ type: NeedType = .miscellany) {}
    func setLocation(fromDefaults: Bool, city: String = "", state: String = "") {}
    func getLocationData() -> NeedsDbWriter.LocationInfo {
        let loc = getLocation()
        return NeedsDbWriter.LocationInfo(city: loc.city, state: loc.state, country: loc.country, address: nil, geoLocation: nil)
    }
    func setHeadline(_ headline: String? = "", description: String? = "") {}
}

extension String {
    func taloneDatabaseValue() -> String {
        return self.capitalized
    }
}

class DatabaseReadyClass: NSObject {

    func getAllKeys(myClass: AnyClass) -> [String] {
        var propertiesCount: CUnsignedInt = 0
        print(myClass)
        guard let propertiesInAClass = class_copyPropertyList(myClass, &propertiesCount) else {
            if myClass.self is Keyed.Type {
                return myClass.keys()
            } else { return [] }
        }
        var propertiesArray: [String] = []
        for i in 0..<propertiesCount {
            let property = propertiesInAClass[Int(i)]
            if let propName = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue) {
                let name = String(propName)
                propertiesArray.append(name)
            }
        }
        return propertiesArray
    }
    
    func propertyValue(_ key: String) -> AnyObject? {
        return self.value(forKey: key) as AnyObject?
    }
    
    @objc func propertyClass(_ key: String) -> AnyClass? {
        if let k = propertyValue(key) as? NSObject {
            return type(of: k)
        }
        return nil
    }
}

class CityState: DatabaseReadyClass, NSSecureCoding {
    
    enum CodingKeys: String, DatabaseReady {
        case city, state, country
    }
    
    let city: String
    let state: String
    let country = "USA"
    
    static var supportsSecureCoding: Bool = true
    
    func displayName() -> String {
        return city + ", " + state
    }
    
    init(city: String, state: String) {
        self.city = city
        self.state = state
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(city, forKey: CodingKeys.city.databaseValue())
        coder.encode(state, forKey: CodingKeys.state.databaseValue())
        coder.encode(country, forKey: CodingKeys.country.databaseValue())
    }
    
    required convenience init?(coder: NSCoder) {
        guard
            let city = coder.decodeObject(forKey: CodingKeys.city.databaseValue()) as? String,
            let state = coder.decodeObject(forKey: CodingKeys.state.databaseValue()) as? String
            //let country = coder.decodeObject(forKey: CodingKeys.country.databaseValue()) as? String
        else {
            return nil
        }
        self.init(city: city, state: state)
    }
}

