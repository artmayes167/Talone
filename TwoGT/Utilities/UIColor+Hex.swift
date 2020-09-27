//
//  UIColor+Hex.swift
//  TridentPre
//
//  Created by Juan C. Mendez on 11/1/17.
//  Copyright © 2017 Carnival. All rights reserved.
//

import UIKit

extension UIColor {
  class func hex(_ hex: NSString) -> UIColor {
    var cString: NSString = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased() as NSString
    
    if cString.length < 6 { return UIColor.gray }
    if cString.hasPrefix("0X") || cString.hasPrefix("0x") { cString = cString.substring(from: 2) as NSString }
    if cString.length != 6 { return UIColor.gray }
    
    // Separate into r, g, b substrings
    var range = NSRange(location: 0, length: 2)
    let rString = cString.substring(with: range)
    
    range.location = 2
    let gString = cString.substring(with: range)
    
    range.location = 4
    let bString = cString.substring(with: range)
    
    // Scan values
    var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
    Scanner(string: rString).scanHexInt64(&r)
    Scanner(string: gString).scanHexInt64(&g)
    Scanner(string: bString).scanHexInt64(&b)
    
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
  }
}
