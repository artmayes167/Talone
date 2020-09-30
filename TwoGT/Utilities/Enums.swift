//
//  Enums.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

//@objc protocol Keyed {
//    @objc static func keys() -> [String]
//}

/// Used specifically for `RawRepresentables` with `rawValue == String`.  Default implementation returns a `String.capitalized` if applicable, and an empty `String` if `rawValue` fails to translate.
   /// - Returns: The `String` value of the `RawRepresentable`, formatted according to backend developer preferences.
protocol DatabaseReady: RawRepresentable, CaseIterable {
    func firebaseValue() -> String
    func coreDataValue() -> String?
}

extension DatabaseReady {
    func firebaseValue() -> String {
        if let v = self.rawValue as? String {
            return v.taloneDatabaseValue()
        }
        return ""
    }
    
    func coreDataValue() -> String? {
        if let v = self.rawValue as? String {
            return v
        }
        return nil
    }
}

enum DefaultsKeys: String, CaseIterable {
    case lastUsedLocation, taloneEmail, userHandle, uid
}

enum ProfileButtonType {
    case me, card
}

enum NeedType: String, CaseIterable, DatabaseReady {
    case none, food, clothes, shelter, furniture, service, miscellany
}

enum AddressType: String, CaseIterable, DatabaseReady {
    case home, retail, office, other, custom  // custom for a temporary address
}
