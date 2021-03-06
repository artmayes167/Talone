//
//  PurposeCreationManager.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

enum CurrentCreationType: Int {
    case need, have, unknown

    func stringValue() -> String {
        switch self {
        case .have:
            return "have"
        case .need:
            return "need"
        default:
            return "none"
        }
    }
}

class PurposeCreationManager: NSObject {

    private var creationType: CurrentCreationType = .unknown
    private var category: NeedType = .any
    private var location: CityStateSearchVC.Loc?
    private var headline: String?
    private var desc: String?

    func setCreationType(_ type: CurrentCreationType) {
        creationType = type
    }

    func currentCreationType() -> CurrentCreationType {
        return creationType
    }

    func setCategory(_ type: NeedType) {
        category = type
    }

    func getCategory() -> NeedType? {
        return category
    }

    func setLocation(_ loc: CityStateSearchVC.Loc) {
        location = loc
    }

    func getLocationOrNil() -> CityStateSearchVC.Loc? {
        return location
    }

    /// - Returns: `true` if able to set both headline and description,` false` otherwise
    func setHeadline(_ headline: String?, description: String?) -> Bool {
        self.headline = headline
        self.desc = description
        if let h = headline, !h.isEmpty, let d = description, !d.isEmpty, category != .any {
            return true
        }
        return false
    }

    func getHeadline() -> String? {
        return headline
    }

    func getDescription() -> String? {
        return desc
    }
}
