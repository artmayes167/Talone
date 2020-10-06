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
    
    var contact: Contact? {
        didSet { if isViewLoaded { populateUI() } }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    private func populateUI() {
        guard let c = contact else { return }
        
        headerView.setTitleText("contact with \(c.contactHandle)")
        
        if let t = c.receivedCards?.first {
            theirCard = t
            let color = leftView.backgroundColor
            let newColor = color?.withAlphaComponent(0.9)
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
        
        if let m = c.sentCards?.first {
            myCard = m
            let color = rightView.backgroundColor
            let newColor = color?.withAlphaComponent(0.9)
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
            showCompleteAndSendCardHelper(card: theirCard)
        default:
            fatalError()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toTheirContact":
            guard let vc = segue.destination as? TheirContactVC else { fatalError() }
            vc.theirCard = theirCard
        case "toMyContact":
            guard let vc = segue.destination as? MyContactVC else { fatalError() }
            vc.myCard = myCard
        default:
            print("Different segue = \(String(describing: segue.identifier))")
        }
    }
}
