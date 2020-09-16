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

class PurposeCreationManager: NSObject, PurposeInitializationProtocol {
    
    private var purpose: PurposeClass?
    private var need: Need?
    private var have: Have?
    private var creationType: CurrentCreationType = .unknown
    
    convenience init?(withType: NeedType, state: String) {
        self.init()
        let cityState = CityState(locationInfo: AppLocationInfo(city: "", state: state), community: "")
        purpose = PurposeClass.init(category: withType.rawValue, cityState: cityState, needs: [], haves: [], events: [])
        createTemplateNeedAndHave()
    }
    
    convenience init?(locationInfo: AppLocationInfo) {
        self.init()
        let cityState = CityState(locationInfo: locationInfo, community: "")
        purpose = PurposeClass.init(category: NeedType.none.rawValue, cityState: cityState, needs: [], haves: [], events: [])
        createTemplateNeedAndHave()
    }
    
    private func createTemplateNeedAndHave() {
        let item = Item(id: "", headline: "", eventDescription: "", category: "", createdBy: "", createdAt: 0, haveDescription: "", needDescription: "")
        need = Need(fulfilled: false, needItem: item, personalNotes: nil, needIDS: nil, haveIDS: nil, eventIDS: nil)
        have = Have(haveItem: item, personalNotes: nil, needIDS: nil, haveIDS: nil, eventIDS: nil)
        
    }
    
    func setCreationType(_ type: CurrentCreationType) {
        creationType = type
    }
    
    func setCategory(_ type: NeedType) {
        purpose?.category = type.rawValue
    }
    
    func getCategory() -> NeedType {
        if let p = purpose {
            return NeedType(rawValue: p.category) ?? .none
        } else {
            fatalError()
        }
    }
    
    func setLocation(cityState: CityState) {
        purpose?.cityState = cityState
    }
    
    func setLocation(location: AppLocationInfo) {
        purpose?.cityState.locationInfo = location
    }
    
    func setLocation(city: String, state: String, country: String) {
        purpose?.cityState = CityState(locationInfo: AppLocationInfo(city: city, state: state, country: country), community: "")
    }
    
    func setCommunity(_ community: String) {
        purpose?.cityState.community = community
    }
    
    func getLocationOrNil() -> CityState? {
        return purpose?.cityState
    }
    
    func getCurrentHeadline() -> String? {
        switch creationType {
        case .have:
            return have?.getHeadlineOrNil()
        case .need:
            return need?.getHeadlineOrNil()
        default:
            return nil
        }
    }
    
    func getCurrentDescription() -> String? {
        switch creationType {
        case .have:
            return have?.getNotesOrNil()
        case .need:
            return need?.getNotesOrNil()
        default:
            return nil
        }
    }
    
    func areAllRequiredFieldsFilled(light: Bool) -> Bool {
        guard let _ = purpose else { return false }
        switch creationType {
        case .have:
            return have?.areAllRequiredFieldsFilled(light: light) ?? false
        case .need:
            return need?.areAllRequiredFieldsFilled(light: light) ?? false
        default:
            return false
        }
    }
    
    func setHeadline(_ headline: String?, description: String?) {
        switch creationType {
        case .have:
            guard let h = have?.haveItem else { fatalError() }
            h.headline = headline
            h.haveDescription = description
        case .need:
            guard let n = need?.needItem else { fatalError() }
            n.headline = headline
            n.needDescription = description
        default:
            return
        }
    }
    
}
