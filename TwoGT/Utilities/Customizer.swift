//
//  Customizer.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class Customizer {
    
    static let shared = Customizer()
    private var theme: CustomTheme = .defaultTheme
    var tabBarButtonSelected: UIColor = .lightGray
    var tabBarButtonUnselected: UIColor = .clear
    
    func setTheme(_ ct: CustomTheme) {
        UserDefaults.standard.set(theme, forKey: "theme")
        theme = ct
    }
}

extension UIColor {
    
    var activeTextViewBorder: UIColor {
        get {
            return UIColor.hex("#047244").withAlphaComponent(0.67)
        }
    }
    
}
