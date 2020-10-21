//
//  RatingVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

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
        didSet { updateUI() }
    }
    
    override func updateUI() {
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
    
    fileprivate lazy var ratings: NSFetchedResultsController<ContactRating> = {
        let context = CoreDataGod.managedContext
      //let request: NSFetchRequest<Contact> = NSFetchRequest(entityName: "Contact")
        let request: NSFetchRequest<ContactRating> = ContactRating.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ContactRating.contactHandle), ascending: false)]
      let ratings = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      return ratings
    }()
    
    func configure(contact: Contact) {
        do {
          try ratings.performFetch()
        } catch {
          print("Error: \(error)")
        }
        
        if let objects = self.ratings.fetchedObjects {
            for rating in objects where contact.contactHandle == rating.contactHandle {
                self.rating = rating
                return
            }
        }
        _ = ContactRating.create(handle: contact.contactHandle!)
        CoreDataGod.save()
        configure(contact: contact)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
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
        guard let b = Int64(String(badLabel.text!)), let j = Int64(String(justLabel.text!)), let g = Int64(String(goodLabel.text!)) else { return }
        r.bad = b
        r.justSo = j
        r.good = g
        CoreDataGod.save()
    }
}
