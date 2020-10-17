//
//  Array+Extensions.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

extension Array where Iterator.Element == String {
    func indexOf(_ string: String) -> Int? {
        for (i, v) in self.enumerated() {
            if v == string {
                return i
            }
        }
        return nil
    }
}
