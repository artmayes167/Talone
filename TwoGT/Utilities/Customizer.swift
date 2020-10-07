//
//  Customizer.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

/// Any Designable object that can be customized by `Customizer` must conform to this protocol
protocol CustomizedObject: UIView {
    func key() -> UIGroup
}

enum UIGroupElements: String, CaseIterable, DatabaseReady {
    case textColor, textModifier, font, borderColor, borderWidth
}

 // MARK: - Public Class
/// `Customizer` singleton manages the `ThemeConfigurator` object
public class Customizer: NSObject {
    
    static let shared = Customizer(nil)
    
    fileprivate var configurator: ThemeConfigurator?
    var tabBarButtonSelected: UIColor = .lightGray
    var tabBarButtonUnselected: UIColor = .clear
    
    fileprivate convenience init(_ theme: CustomThemeName?) {
        self.init()
        configurator = ThemeConfigurator(theme: theme)
    }
    
    public func setThemeString(theme: String) {
        guard let t = CustomThemeName(rawValue: theme) else { fatalError() }
        setTheme(t)
    }
    
    func customize(_ view: CustomizedObject) {
        switch view.key() {
        case .activeTextView, .inactiveTextView:
            guard let v = view as? DesignableTextView else { fatalError() }
            configure(textView: v)
        case .pageHeader, .secondaryPageHeader, .cardPrimaryHeader:
            guard let v = view as? DesignableView else { fatalError() }
            configure(view: v)
        case .modalBackButton:
            guard let v = view as? DesignableButton else { fatalError() }
            configure(button: v)
        case .topCap, .bottomCap:
            guard let v = view as? DesignableImage else { fatalError() }
            configure(imageView: v)
        case .addressCell, .phoneCell, .emailCell:
            guard let v = view as? UITableViewCell else { fatalError() }
            configure(tableCell: v)
        }
    }
}

extension Customizer {
    // TODO: - Set up theme selection UI
    fileprivate func setTheme(_ ct: CustomThemeName) {
        guard let c = configurator else {
            configurator = ThemeConfigurator(theme: ct)
            return
        }
        c.loadTheme(key: ct)
    }
    
    fileprivate func configure(textView: DesignableTextView) {
        if let v = textView as? ActiveTextView {
            v.borderColor = UIColor.hex("#047244").withAlphaComponent(0.77)
            v.backgroundColor = .white
            return
        }
        if let v = textView as? InactiveTextView {
            v.borderColor = .black
            v.backgroundColor = .white
            return
        }
    }
    
    fileprivate func configure(button: DesignableButton) {
        if let b = button as? ModalBackButton {
            b.setImage(UIImage(named: "downArrow"), for: .normal)
            b.setTitle("", for: .normal)
            b.tintColor = .purple
            b.backgroundColor = .white
            b.borderWidth = 2
            b.borderColor = .purple
            b.cornerRadius = 8
            b.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        }
    }
    
    fileprivate func configure(view: DesignableView) {
        if let v = view as? PageHeader {
            // Values will come from
            v.titleLabel?.text = UIKeyTranslator().textForUIKey(key: .lowercase, string:  v.titleLabel?.text ?? "Developer Error")
            v.titleLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: .thin)
            v.titleLabel?.textColor = .black
            v.titleLabel?.backgroundColor = .clear
            view.backgroundColor = UIColor.hex("CDDDD1")
            view.borderColor = .black
            view.borderWidth = 2
        }
        
        else if let v = view as? SecondaryPageHeader {
            // Values will come from
            v.titleLabel!.text = UIKeyTranslator().textForUIKey(key: .lowercase, string:  v.titleLabel?.text ?? "Developer Error")
            v.titleLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: .thin)
            v.titleLabel?.textColor = .black
            v.titleLabel?.backgroundColor = .clear
            view.backgroundColor = UIColor.hex("D8CEDD")
            view.borderColor = .black
            view.borderWidth = 2
        }
        
        else if let v = view as? CardPrimaryHeader {
            // Values will come from
            v.titleLabel!.text = UIKeyTranslator().textForUIKey(key: .lowercase, string:  v.titleLabel?.text ?? "Developer Error")
            v.titleLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: .thin)
            v.titleLabel?.textColor = .black
            v.titleLabel?.backgroundColor = .clear
            view.backgroundColor = UIColor.hex("85A682").withAlphaComponent(0.77)
            view.borderColor = .black
            view.borderWidth = 0
        }
    }
    
    fileprivate func configure(imageView: DesignableImage) {
        if let v = imageView as? TopCap {
            v.image = UIImage(named: "sun")
            v.tintColor = .systemBlue
        }
        else if let v = imageView as? BottomCap {
            v.image = UIImage(named: "sunBottom")
            v.tintColor = .systemBlue
        }
    }
    
    fileprivate func configure(tableCell: UITableViewCell) {
        if let v = tableCell as? ParentAddressTableViewCell {
            v.contentView.backgroundColor = UIColor.hex("CEDCCF")
        }
        else if let v = tableCell as? ParentEmailTableViewCell {
            v.contentView.backgroundColor = UIColor.hex("BECBE3")
        }
        else if let v = tableCell as? ParentPhoneTableViewCell {
            v.contentView.backgroundColor = UIColor.hex("DBD9DE")
        }
    }
}

class UIKeyTranslator: NSObject {
    func textForUIKey(key: UITextModifiers, string: String) -> String {
        switch key {
        case .lowercase:
            return string.lowercased()
        case .uppercase:
            return string.uppercased()
        case .capitalized:
            return string.capitalized
        }
    }
}

 // MARK: - Internal Classes

private enum CustomThemeName: String, CaseIterable, DatabaseReady {
    case defaultTheme
}

/// Encapsulates theme information, privately managed by `ThemeConfigurator`.
/// Only reference inside `ThemeConfigurator`
private class Theme {
    private var themeType: CustomThemeName? {
        didSet {
            populate()
        }
    }
    
    private var dict: [UIGroup: [UIGroupElements: String]]?
    
    class func newTheme(_ key: CustomThemeName) -> Theme {
        let t = Theme(key)
        t.populate()
        return t
    }
    
    private convenience init(_ key: CustomThemeName) {
        self.init()
        if key == .defaultTheme, let ct = UserDefaults.standard.string(forKey: "taloneTheme"), let themeKey = CustomThemeName(rawValue: ct) {
            themeType = themeKey
            return
        }
        UserDefaults.standard.setValue(key.rawValue, forKey: "taloneTheme")
        themeType = key
    }
    
    private func populate() {
        
    }
    
    func isNewTheme(key: CustomThemeName) -> Bool {
        return themeType != key
    }
}

/// Manages creation and application of ` Theme`s
private class ThemeConfigurator: NSObject {
   
    private var theme: Theme?
    
    convenience init(theme: CustomThemeName?) {
        self.init()
        loadTheme(key: theme ?? .defaultTheme)
    }
    
    /// Theme is self-populating when initialized with key
    func loadTheme(key: CustomThemeName) {
        if (theme?.isNewTheme(key: key) ?? false) {
            theme = Theme.newTheme(key)
        }
    }
}
