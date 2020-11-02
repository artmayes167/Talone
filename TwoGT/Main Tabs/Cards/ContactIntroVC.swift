//
//  ContactIntroVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/5/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ContactIntroVC: UIViewController {
    
    @IBOutlet weak var headerView: SecondaryPageHeader!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var theirCard: CardTemplateInstance?
    var myCard: CardTemplateInstance?
    
    private var contact: Contact? { didSet { if isViewLoaded { populateUI() } } }
    
    func set(contact: Contact) {
        CoreDataGod.managedContext.refresh(contact, mergeChanges: true)
        self.contact = contact
        if let sent = contact.sentCards {
            if let s = sent.last {
                CoreDataGod.managedContext.refresh(s, mergeChanges: true)
                myCard = s
            }
        }
        if let rec = contact.receivedCards {
            if let r = rec.last {
                CoreDataGod.managedContext.refresh(r, mergeChanges: true)
                theirCard = r
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    override func updateUI() {
        populateUI()
        presentationController?.delegate?.updateUI()
    }
    
    private func populateUI() {
        guard let c = contact else { return }
        
        headerView.setTitleText("contact with " + c.contactHandle!)
        
        if let _ = theirCard {
            let color = leftView.backgroundColor
            let newColor = color?.withAlphaComponent(0.77)
            leftView.backgroundColor = newColor
            leftButton.setTitle("see their card".taloneCased(), for: .normal)
            leftButton.isEnabled = true
        } else {
            let color = leftView.backgroundColor
            let newColor = color?.withAlphaComponent(1.0)
            leftView.backgroundColor = newColor
            leftButton.setTitle("no cards".taloneCased(), for: .normal)
            leftButton.isEnabled = false
        }
        
        if let _ = myCard {
            let color = rightView.backgroundColor
            let newColor = color?.withAlphaComponent(0.77)
            rightView.backgroundColor = newColor
            rightButton.setTitle("see your card".taloneCased(), for: .normal)
        } else {
            let color = rightView.backgroundColor
            let newColor = color?.withAlphaComponent(1.0)
            rightView.backgroundColor = newColor
            rightButton.setTitle("send new card".taloneCased(), for: .normal)
        }
    }
    
    @IBAction func seeTheirCard(_ sender: UIButton!) {
        performSegue(withIdentifier: "toTheirContact", sender: nil)
    }
        
    @IBAction func seeMyCard(_ sender: UIButton!) {
        switch sender.title(for: .normal) {
        case "see your card".taloneCased():
            performSegue(withIdentifier: "toMyContact", sender: nil)
        case "send new card".taloneCased():
            showCompleteAndSendCardHelper(contact: contact)
        default:
            fatalError()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toTheirContact":
            guard let vc = segue.destination as? TheirContactVC else { fatalError() }
            guard let c = contact else { fatalError() }
            vc.set(contact: c)
            segue.destination.presentationController?.delegate = self
        case "toMyContact":
            guard let vc = segue.destination as? MyContactVC else { fatalError() }
            guard let c = contact else { fatalError() }
            vc.set(contact: c)
            segue.destination.presentationController?.delegate = self
        default:
            print("Different segue = \(String(describing: segue.identifier))")
            segue.destination.presentationController?.delegate = self
        }
    }
    
    @IBAction func unwindToMainContact( _ segue: UIStoryboardSegue) { }
}
