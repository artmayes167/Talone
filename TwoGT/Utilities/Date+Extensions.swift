//
//  Date+Extensions.swift
//  UsefulCode
//
//  Created by Mayes, Arthur E. on 2/18/19.
//  Copyright © 2019 Mayes, Arthur E. All rights reserved.
//

import Foundation

extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium

        return dateFormatter.string(from: date)
    }
}
