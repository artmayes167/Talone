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
    func setLocation(fromDefaults: Bool, city: String, state: String) 
    func isLocationValid() -> Bool
    func getLocation() -> CityState
    func getCurrentHeadline() -> String
    func getCurrentDescription() -> String
    func areAllRequiredFieldsFilled(light: Bool) -> Bool
    func setHeadline(_ headline: String?, description: String?)
}

extension Purpose {
    func setLocation(fromDefaults: Bool, city: String = "", state: String = "") {}
}

struct CityState: Encodable {
    let city: String
    let state: String
    let country = "USA"
}
