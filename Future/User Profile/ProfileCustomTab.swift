//
//  ProfileCustomTab.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

enum ProfileButtonType {
    case me, card
}

class ProfileCustomTab: UIViewController, ProfileTabDelegate {
    
    @IBOutlet weak var meContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var profileTab: ProfileTabs!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTab.delegate = self
        profileTab.configure(for: .me)
    }

    func touched(tab: ProfileButtonType) {
        switch tab {
        case .me:
            meContainer.isHidden = false
            cardContainer.isHidden = true
        case .card:
            meContainer.isHidden = true
            cardContainer.isHidden = false
        }
    }
}

class TabButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                backgroundColor = Customizer.shared.tabBarButtonSelected
                    .withAlphaComponent(0.9)
                
            } else {
                backgroundColor = Customizer.shared.tabBarButtonUnselected
                
            }
        }
    }
}

protocol ProfileTabDelegate {
    func touched(tab: ProfileButtonType)
}

class ProfileTabs: UIView {
    
    @IBOutlet weak var meButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    
    var delegate: ProfileTabDelegate?
    
    func configure(for button: ProfileButtonType) {
        switch button {
        case .me:
            meButton.isSelected = true
            cardButton.isSelected = false
            delegate?.touched(tab: .me)
            
        case .card:
            meButton.isSelected = false
            cardButton.isSelected = true
            delegate?.touched(tab: .card)
        }
    }
    
    @IBAction func touchedMe(_ sender: Any) {
        configure(for: .me)
    }
    
    @IBAction func touchedCard(_ sender: Any) {
        configure(for: .card)
    }
}
