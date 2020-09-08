//
//  Enums.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

enum ProfileButtonType {
    case me, card
}

enum CustomTheme {
    case defaultTheme
}

enum NeedType: String, CaseIterable {
    case food, clothes, shelter, furniture, miscellany
}

enum AddressType {
    case home, retail, office, other, custom  // custom for a temporary address
}
