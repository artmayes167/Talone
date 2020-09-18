//
//  CoreDataObjectExtensions.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation


extension CityState {
    convenience init?(locationInfo: AppLocationInfo) {
        self.init()
        self.city = locationInfo.city
        self.state = locationInfo.state
        self.country = locationInfo.country
    }
    
    func displayName() -> String {
        if let c = city, let s = state {
            return c.capitalized + ", " + s.capitalized
        } else { fatalError() }
    }
    
    func locationInfo() -> AppLocationInfo {
        let a = AppLocationInfo()
        a.city = self.city
        a.state = self.state
        a.country = self.country
        return a
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
    func displayName() -> String {
        if let c = city, let s = state {
            return c.capitalized + ", " + s.capitalized
        } else { fatalError() }
    }
}

extension AppLocationInfo {
    convenience init?(city: String, state: String, country: String) {
        self.init()
        self.city = city
        self.state = state
        self.country = country
    }
}

extension Address {
    convenience init?(locationInfo: AppLocationInfo) {
        self.init()
        self.city = locationInfo.city
        self.state = locationInfo.state
        self.country = locationInfo.country
    }
    
    func locationInfo() -> AppLocationInfo {
        let a = AppLocationInfo()
        a.city = self.city
        a.state = self.state
        a.country = self.country
        return a
    }
}
