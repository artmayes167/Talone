//
//  PresenceAndRatingDisplay.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class PresenceAndRatingDisplay: UIView {

    @IBOutlet weak var themImageView: UIImageView!
    @IBOutlet weak var meImageView: UIImageView!
    
    var contact: Contact? {
        didSet {
            if let c = contact {
                CoreDataGod.managedContext.refresh(c, mergeChanges: true)
                configureWith(contact: c)
            }
        }
    }
    
    private func configureWith(contact: Contact) {
        if let _ = contact.receivedCards?.first {
            themImageView.image = UIImage(named: "contactsBook")
        } else {
            themImageView.image = UIImage(named:"whoSmall")
        }
        
        if let _ = contact.sentCards?.first {
            meImageView.image = UIImage(named: "contactsBook")
        } else {
            meImageView.image = UIImage(named:"whoSmall")
        }
        
        themImageView.tintColor = colorFor(rating: contact.rating?.last)
        meImageView.tintColor = colorFor(rating: nil)
    }
    
    func colorFor(rating: ContactRating?) -> UIColor {
        guard let r = rating else { return .systemPurple }
        let g = r.good
        let j = r.justSo
        let b = r.bad
        
        if j > g && j > b { return .systemPurple }
        
        switch g > b {
        case true:
            if g > j { return .systemGreen }
        case false:
            if b > j { return .systemRed }
        }
        return .systemPurple
    }
}
