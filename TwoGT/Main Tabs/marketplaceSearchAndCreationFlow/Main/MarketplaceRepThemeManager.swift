//
//  MarketplaceRepThemeManager.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class MarketplaceRepThemeManager {
    enum RepTheme: String, CaseIterable {
        case bad
        case kindaBad
        case justSo
        case kindaGood
        case good
        case unknown
    }
    
    //private
    func themeFor(_ count: Float) -> UIColor {
        switch true {
        case count >= 0 && count < 0.2:
            return colorFor(.bad)
        case count >= 0.2 && count < 0.4:
            return colorFor(.kindaBad)
        case count >= 0.4 && count < 0.6:
            return colorFor(.justSo)
        case count >= 0.6 && count < 0.8:
            return colorFor(.kindaGood)
        case count >= 0.8 && count < 1.0:
            return colorFor(.good)
        default:
            return colorFor(.unknown)
        }
    }
    
    //private
    func colorFor(_ theme: RepTheme) -> UIColor {
        switch theme {
        case .bad:
            return .systemRed
        case .kindaBad:
            return .systemYellow
        case .justSo:
            return .systemIndigo
        case .kindaGood:
            return .systemBlue
        case .good:
            return .systemGreen
        case .unknown:
            return .clear
        }
    }
}
