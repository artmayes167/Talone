//
//  RatingVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class RatingButton: UIButton {
    var isConfiguredForSelected: Bool = false
    func setForSelection(_ selected: Bool) {
        isConfiguredForSelected = selected
        if selected {
            imageView?.doGlowAnimation(withColor: .white, withEffect: .big)
        } else {
            imageView?.endGlowAnimation()
        }
    }
}

class RatingVC: UIViewController {
    
    @IBOutlet weak var badLabel: UILabel!
    @IBOutlet weak var justLabel: UILabel!
    @IBOutlet weak var goodLabel: UILabel!
    
    @IBOutlet weak var badButton: RatingButton!
    @IBOutlet weak var justButton: RatingButton!
    @IBOutlet weak var goodButton: RatingButton!
    
    private var adder = 1
    
    private var badCount: Int = 0
    private var justCount: Int = 0
    private var goodCount: Int = 0
    
    private var rating: ContactRating? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let r = rating {
            if isViewLoaded {
                goodCount = Int(r.good)
                justCount = Int(r.justSo)
                badCount = Int(r.bad)
                
                badLabel.text = String(badCount)
                justLabel.text = String(justCount)
                goodLabel.text = String(goodCount)
            }
        }
    }
    
    func configure(contact: Contact) {
        if let r = contact.rating {
            if r.isEmpty {
                let rating = ContactRating.create(handle: contact.contactHandle)
                self.rating = rating
            } else {
                rating = r.first
            }
        } else {
            let rating = ContactRating.create(handle: contact.contactHandle)
            self.rating = rating
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func touched(_ sender: RatingButton) {
        let buttons : [RatingButton] = [badButton, justButton, goodButton]
        sender.setForSelection(!sender.isConfiguredForSelected)
        
        if sender.isConfiguredForSelected {
            let filteredButtons = buttons.filter { $0 != sender }
            _ = filteredButtons.map { $0.setForSelection(false) }
        }
        for x in buttons {
            switch x {
            case badButton:
                badLabel.text = x.isConfiguredForSelected ? String(badCount + adder) : String(badCount)
            case justButton:
                justLabel.text = x.isConfiguredForSelected ? String(justCount + adder) : String(justCount)
            case goodButton:
                goodLabel.text = x.isConfiguredForSelected ? String(goodCount + adder) : String(goodCount)
            default:
                fatalError()
            }
        }
        guard let r = rating else { fatalError() }
        guard let b = Int64(String(badLabel.text!)), let j = Int64(String(badLabel.text!)), let g = Int64(String(badLabel.text!)) else { return }
        r.bad = b
        r.justSo = j
        r.good = g
        try? CoreDataGod.managedContext.save()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
