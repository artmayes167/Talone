//
//  Enums.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

/// Used specifically for `RawRepresentables` with `rawValue == String`.  Default implementation returns a `String.capitalized` if applicable, and an empty `String` if `rawValue` fails to translate.
   /// - Returns: The `String` value of the `RawRepresentable`, formatted according to backend developer preferences.
protocol DatabaseReady: RawRepresentable {
    func databaseValue() -> String
}

extension DatabaseReady {
    func databaseValue() -> String {
        if let v = self.rawValue as? String {
            return v.capitalized
        }
        return ""
    }
}

enum ProfileButtonType {
    case me, card
}

enum CustomTheme: String, CaseIterable, DatabaseReady {
    case defaultTheme
}

enum NeedType: String, CaseIterable, DatabaseReady {
    case food, clothes, shelter, furniture, miscellany
}

enum AddressType: String, CaseIterable, DatabaseReady {
    case home, retail, office, other, custom  // custom for a temporary address
}
