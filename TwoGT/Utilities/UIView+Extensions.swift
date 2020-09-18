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

 // MARK: - DesignableButton and associated classes
@IBDesignable class DesignableButton: UIButton {}
/// UIViewController conforms to ModalBackButtonDelegate protocol
protocol ModalBackButtonDelegate: UIViewController {}

class ModalBackButton: DesignableButton {
    var delegate: ModalBackButtonDelegate?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      commonInit()
    }

    private func commonInit() {
        // set color scheme/image
        self.setImage(UIImage(named: "downArrow"), for: .normal)
        self.setTitle("", for: .normal)
        self.tintColor = .black
        self.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
}

@IBDesignable class DesignableTextField: UITextField {}
@IBDesignable class DesignableSegmentedControl: UISegmentedControl {}

 // MARK: - DesignableTextView and associated classes
@IBDesignable public class DesignableTextView: UITextView {}

class ActiveTextView: DesignableTextView {
    let color = UIColor().activeTextViewBorder
    
    override func didMoveToSuperview() {
        borderColor = color
        backgroundColor = .white
        super.didMoveToSuperview()
    }
}
