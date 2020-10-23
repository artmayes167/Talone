//
//  Enums.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

/// Used specifically for `RawRepresentables` with `rawValue == String`.  Default implementation returns a `String.capitalized` if applicable, and an empty `String` if `rawValue` fails to translate.
protocol DatabaseReady: RawRepresentable, CaseIterable {
    /// - Returns: The `String` value of the `RawRepresentable`, formatted according to backend developer preferences.
    func firebaseValue() -> String
    /// - Returns: The `String` value of the `RawRepresentable`, formatted according to core data developer preferences.
    func coreDataValue() -> String?
}

/// Default implementation
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

/// Specifically for storage prior to dragon creation
enum DefaultsKeys: String, CaseIterable {
    case lastUsedLocation, taloneEmail, userHandle, uid
}

/// Current viewable and shareable string-representible element types (excludes image)
enum CardElementTypes: String, RawRepresentable {
    case address, phoneNumber, email
}
