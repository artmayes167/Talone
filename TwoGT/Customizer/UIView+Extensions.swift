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

extension UISegmentedControl {
    @IBInspectable public var titleColor: UIColor {
        set {
            var attributes = self.titleTextAttributes(for: state) ?? [:]
            attributes[.foregroundColor] = newValue
            self.setTitleTextAttributes(attributes, for: state)
        }
        get {
            let attributes = self.titleTextAttributes(for: state) ?? [:]
            return attributes[.foregroundColor] as! UIColor
        }
    }
    
//    func setTitleFont(_ font: UIFont, state: UIControl.State = .normal) {
//        var attributes = self.titleTextAttributes(for: state) ?? [:]
//        attributes[.font] = font
//        self.setTitleTextAttributes(attributes, for: state)
//    }
}

/// Parent classes for display in Storyboard
@IBDesignable class DesignableImage: UIImageView {}
@IBDesignable class DesignableView: UIView {}

 // MARK: - DesignableButton
///  Associated classes in ClassesForCustomizer
@IBDesignable class DesignableButton: UIButton {
//    override func willMove(toSuperview newSuperview: UIView?) {
//        doGlowAnimation(withColor: .white)
//    }
}

@IBDesignable class DesignableTextField: UITextField {}
@IBDesignable class DesignableSegmentedControl: UISegmentedControl {}

 // MARK: - DesignableTextView
///  Associated classes in ClassesForCustomizer
@IBDesignable public class DesignableTextView: UITextView {}

@IBDesignable class DesignableLabel: UILabel {}

@IBDesignable class DesignableStack: UIStackView {}

extension UIView {

  enum GlowEffect: Float {
    case small = 0.4, normal = 5, big = 15
  }
  
  func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .normal) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowRadius = 0
    layer.shadowOpacity = 1
    layer.shadowOffset = CGSize(width: 0, height: 0)
    
//    let glowAnimationRadius = CABasicAnimation(keyPath: "shadowRadius")
//    glowAnimationRadius.fromValue = 0
//    glowAnimationRadius.toValue = effect.rawValue
//    glowAnimationRadius.beginTime = CACurrentMediaTime()+0.3
//    glowAnimationRadius.duration = CFTimeInterval(1.3)
//    glowAnimationRadius.fillMode = .removed
//    glowAnimationRadius.autoreverses = true
//    glowAnimationRadius.repeatCount = .infinity
//    layer.add(glowAnimationRadius, forKey: "shadowGlowingAnimationRadius")
    
    let glowAnimationOpacity = CABasicAnimation(keyPath: "shadowOpacity")
    glowAnimationOpacity.fromValue = 0
    glowAnimationOpacity.toValue = 1
    glowAnimationOpacity.beginTime = CACurrentMediaTime()  //+0.3
    glowAnimationOpacity.duration = CFTimeInterval(1.3)
    glowAnimationOpacity.fillMode = .removed
    glowAnimationOpacity.autoreverses = true
    glowAnimationOpacity.repeatCount = .infinity
    layer.add(glowAnimationOpacity, forKey: "shadowGlowingAnimationOpacity")
  }
    
    func endGlowAnimation() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
//        layer.removeAnimation(forKey: "shadowGlowingAnimationRadius")
        layer.removeAnimation(forKey: "shadowGlowingAnimationOpacity")
    }
}

extension UIImageView {
    func cycleOpacity() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.3
        animation.toValue = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.duration = CFTimeInterval(1.5)
        layer.add(animation, forKey: "fadeToCover")
    }
    
    func endCycleOpacity() {
        layer.removeAnimation(forKey: "fadeToCover")
    }
}
