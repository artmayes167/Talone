//
//  String+Extensions.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

extension String {
    func localized(_ comment: String = "This translation should be self-explanatory") -> String {
      return NSLocalizedString(self, comment: comment)
    }
}
