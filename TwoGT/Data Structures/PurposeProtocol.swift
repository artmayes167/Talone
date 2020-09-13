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

struct CityState: Encodable, Equatable {
    let city: String
    let state: String
    let country = "USA"
}