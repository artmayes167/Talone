//
//  ClassesForCustomizer.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/26/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

enum UITextModifiers: Int {
    case lowercase, uppercase, capitalized
}

enum UIGroup: String, CaseIterable, DatabaseReady {
    case pageHeader, secondaryPageHeader, cardPrimaryHeader, activeTextView, inactiveTextView, modalBackButton
    case topCap, bottomCap
}

/// Any `UITextView `that the user can type in should subclass this
class ActiveTextView: DesignableTextView, CustomizedObject {
    func key() -> UIGroup {
        return .activeTextView
    }
    override func didMoveToSuperview() {
        Customizer.shared.customize(self)
        super.didMoveToSuperview()
    }
}

class InactiveTextView: DesignableTextView, CustomizedObject {
    func key() -> UIGroup {
        return .inactiveTextView
    }
    override func didMoveToSuperview() {
        Customizer.shared.customize(self)
        super.didMoveToSuperview()
    }
}

/// Any back button in a non-`TabBar`-embedded `UIViewController` should subclass this
class ModalBackButton: DesignableButton, CustomizedObject {
    func key() -> UIGroup {
        return .modalBackButton
    }
    
    override func didMoveToSuperview() {
        Customizer.shared.customize(self)
        super.didMoveToSuperview()
    }
}

/// Must set `titleLabel`
class PageHeader: DesignableView, CustomizedObject {
    func key() -> UIGroup {
        return .pageHeader
    }
    @IBOutlet weak var titleLabel: UILabel?
    
    func setTitleText(_ string: String) {
        titleLabel?.text = string
        Customizer.shared.customize(self)
    }
}

/// Must set `titleLabel`
class SecondaryPageHeader: DesignableView, CustomizedObject {
    func key() -> UIGroup {
        return .secondaryPageHeader
    }
    @IBOutlet weak var titleLabel: UILabel?
    
    func setTitleText(_ string: String) {
        titleLabel?.text = string
        Customizer.shared.customize(self)
    }
}

class CardPrimaryHeader: DesignableView, CustomizedObject {
    func key() -> UIGroup {
        return .cardPrimaryHeader
    }
    @IBOutlet weak var titleLabel: UILabel?
    func setTitleText(_ string: String) {
        titleLabel?.text = string
        Customizer.shared.customize(self)
    }
}

class TopCap: DesignableImage, CustomizedObject {
    func key() -> UIGroup {
        return .topCap
    }
    override func didMoveToSuperview() {
        Customizer.shared.customize(self)
        super.didMoveToSuperview()
    }
}

class BottomCap: DesignableImage, CustomizedObject {
    func key() -> UIGroup {
        return .bottomCap
    }
    override func didMoveToSuperview() {
        Customizer.shared.customize(self)
        super.didMoveToSuperview()
    }
}
