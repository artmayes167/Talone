//
//  ObjectClasses.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

class Need: Purpose {
    var type: NeedType?
    var city = ""
    var state = ""
    var country = "USA"
    var headline = ""
    var description = ""
    var personalNotes = ""
    
    func setCategory(_ type: NeedType) {
        self.type = type
    }
    
    func getCategory() -> NeedType? {
        return type
    }
    
    func setHeadline(_ headline: String?, description: String?) {
        self.headline = headline ?? self.headline
        self.description = description ?? self.description
    }
    
    func getCurrentHeadline() -> String {
        return headline
    }
    
    func getCurrentDescription() -> String {
        return description
    }
    
    func setLocation(fromDefaults: Bool, city: String = "", state: String = "") {
        if fromDefaults {
            self.city = UserDefaults.standard.string(forKey: "currentCity") ?? ""
            self.state = UserDefaults.standard.string(forKey: "currentState") ?? ""
        } else {
            self.city = !city.isEmpty ? city : self.city
            self.state = !state.isEmpty ? state : self.state
            UserDefaults.standard.setValue(self.city, forKeyPath: "currentCity")
            UserDefaults.standard.setValue(self.state, forKeyPath: "currentState")
        }
    }
    
    func isLocationValid() -> Bool {
        return !city.isEmpty && !state.isEmpty
    }
    
    func getLocation() -> CityState {
        return CityState(city: city.capitalized, state: state.capitalized)
    }
    
    private func areHeavyRequirementsMet(_ isLight: Bool) -> Bool {
        if !isLight { return !headline.trimmingCharacters(in: [" "]).isEmpty && !description.trimmingCharacters(in: [" "]).isEmpty }
        return true
    }
    
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        return isLocationValid() && (type != nil) && areHeavyRequirementsMet(light)
    }
}
