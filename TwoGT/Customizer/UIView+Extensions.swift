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

@IBDesignable
class GradientSlider: UISlider {

    @IBInspectable var thickness: CGFloat = 20 {
        didSet {
            setup()
        }
    }

    @IBInspectable var sliderThumbImage: UIImage? {
        didSet {
            setup()
        }
    }

    func setup() {
        let minTrackStartColor = UIColor.red
        let minTrackEndColor = UIColor.yellow
        let maxTrackColor = UIColor.green
        do {
            self.setMinimumTrackImage(try self.gradientImage(
            size: self.trackRect(forBounds: self.bounds).size,
            colorSet: [minTrackStartColor.cgColor, minTrackEndColor.cgColor]),
                                  for: .normal)
            self.setMaximumTrackImage(try self.gradientImage(
            size: self.trackRect(forBounds: self.bounds).size,
            colorSet: [minTrackEndColor.cgColor, maxTrackColor.cgColor]),
                                  for: .normal)
            self.setThumbImage(sliderThumbImage, for: .normal)
            self.thumbTintColor = UIColor.yellow
        } catch {
            self.minimumTrackTintColor = minTrackStartColor
            self.maximumTrackTintColor = maxTrackColor
        }
    }

    func gradientImage(size: CGSize, colorSet: [CGColor]) throws -> UIImage? {
        let tgl = CAGradientLayer()
        tgl.frame = CGRect.init(x:0, y:0, width:size.width, height: size.height)
        tgl.cornerRadius = tgl.frame.height / 2
        tgl.masksToBounds = false
        tgl.colors = colorSet
        tgl.startPoint = CGPoint.init(x:0.0, y:0.5)
        tgl.endPoint = CGPoint.init(x:1.0, y:0.5)

        UIGraphicsBeginImageContextWithOptions(size, tgl.isOpaque, 0.0);
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        tgl.render(in: context)
        let image =

    UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets:
        UIEdgeInsets.init(top: 0, left: size.height, bottom: 0, right: size.height))
        UIGraphicsEndImageContext()
        return image!
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.width,
            height: thickness
        )
    }
    
    override func didChangeValue(forKey key: String) {
        if key == "value" {
            var color = UIColor.yellow
            if value < 0.25 {
                color = .red
            } else if value > 0.75 {
                color = .green
            }
            thumbTintColor = color
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


}

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
