//
//  PurposeCreationManager.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

enum CurrentCreationType: Int {
    case need, have, unknown
}

class PurposeCreationManager: NSObject {
    
    private var purpose: Purpose = Purpose()
    private var need: Need = Need()
    private var have: Have = Have()
    private var creationType: CurrentCreationType = .unknown
    
    convenience init?(withType: NeedType, state: String) {
        self.init()
        let cityState = CityState()
        cityState.state = state
        purpose.category = withType.rawValue
        purpose.cityState = cityState
    }
    
    convenience init?(locationInfo: AppLocationInfo) {
        self.init()
        let cityState = CityState(locationInfo: locationInfo)
        purpose = Purpose()
        purpose.cityState = cityState
    }
    
    func setCreationType(_ type: CurrentCreationType) {
        creationType = type
    }
    
    func setCategory(_ type: NeedType) {
        purpose.category = type.rawValue
    }
    
    func getCategory() -> NeedType {
        return NeedType(rawValue: purpose.category!)! // crash if not
    }
    
    func setLocation(cityState: CityState) {
        purpose.cityState = cityState
    }
    
    func setLocation(location: AppLocationInfo) {
        purpose.cityState = CityState(locationInfo: location)
    }
    
    func setLocation(city: String, state: String, country: String) {
        if let i = AppLocationInfo(city: city, state: state, country: country) {
            purpose.cityState = CityState(locationInfo: i)
        }
    }
    
    func setCommunity(_ community: String) {
        let c = Community()
        c.name = community
        purpose.cityState?.addToCommunities(c)
    }
    
    func getLocationOrNil() -> CityState? {
        return purpose.cityState
    }
    
    func setHeadline(_ headline: String?, description: String?) {
        switch creationType {
        case .have:
            let h = have.haveItem ?? HaveItem()
            h.headline = headline
            h.desc = description
            have.haveItem = h
        case .need:
            let n = need.needItem ?? NeedItem()
            n.headline = headline
            n.desc = description
            need.needItem = n
        default:
            return
        }
    }
    
    func getHeadline() -> String? {
        switch creationType {
        case .have:
            return have.haveItem?.headline
        case .need:
            return need.needItem?.headline
        default:
            return nil
        }
    }
    
    func getDescription() -> String? {
        switch creationType {
        case .have:
            return have.personalNotes
        case .need:
            return need.personalNotes
        default:
            return nil
        }
    }
    
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        switch creationType {
        case .have:
            return have.haveItem?.areAllRequiredFieldsFilled(light: light) ?? false
        case .need:
            return need.needItem?.areAllRequiredFieldsFilled(light: light) ?? false
        default:
            return false
        }
    }
    
}
