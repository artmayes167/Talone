//
//  UIView+Extensions.swift
//  UsefulCode
//
//  Created by Mayes, Arthur E. on 2/14/17.
//  Copyright © 2017 Mayes, Arthur E. All rights reserved.
//

import UIKit

extension UIView {
  /// Allows corner radius of any view to be set in storyboards
  @IBInspectable public var cornerRadius: CGFloat {
    set {
      clipsToBounds = true
      layer.cornerRadius = newValue
    }
    get {
      return layer.cornerRadius
    }
  }
  
  /// Allows border color of any view to be set in storyboards
  @IBInspectable public var borderColor: UIColor {
    set {
      layer.borderColor = newValue.cgColor
    }
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
  }
  
  /// Allows border width of any view to be set in storyboards
  @IBInspectable public var borderWidth: CGFloat {
    set {
      layer.borderWidth = newValue
    }
    get {
      return layer.borderWidth
    }
  }
}

@IBDesignable class DesignableImage: UIImageView {}
@IBDesignable class DesignableView: UIView {}
@IBDesignable class DesignableButton: UIButton {}
@IBDesignable class DesignableTextField: UITextField {}
