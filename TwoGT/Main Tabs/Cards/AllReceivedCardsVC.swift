//
//  AllReceivedCardsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/26/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AllReceivedCardsVC: UIViewController {

    @IBOutlet weak var cardHeaderView: CardPrimaryHeader!
    @IBOutlet weak var tableView: UITableView!
    
    private var contacts: [Contact] = [] {
        didSet {
            var dict: [String: [String]] = [:]
            for c in contacts {
                let firstChar = c.contactHandle!.first!
                if var array = dict[String(firstChar)] {
                    array.append(c.contactHandle!)
                    dict[String(firstChar)] = array
                } else { dict[String(firstChar)] = [c.contactHandle!] }
            }
            contactList = dict
        }
    }
    
    private var contactList: [String: [String]] = [:] {
        didSet { if isViewLoaded { tableView.reloadData() } }
    }
    
    private var contactListKeys: [String] {
        get { return contactList.keys.sorted() }
    }
    
    private func getContacts() {
        CoreDataGod.managedContext.refreshAllObjects()
        contacts = CoreDataGod.user.contacts ?? []
        print(contacts)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("all contacts")
        getContacts()
    }
    
    override func updateUI() {
        getContacts()
        tableView.reloadData()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        getContacts()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCardIntro" {
            let vc = segue.destination as! ContactIntroVC
            let c = sender as! Contact
            vc.set(contact: c)
            segue.destination.presentationController?.delegate = self
        } else {
            segue.destination.presentationController?.delegate = self
        }
    }
}

extension AllReceivedCardsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactListKeys.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactListKeys.count > 5 ? contactListKeys : nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList[contactListKeys[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let handle = contactList[contactListKeys[indexPath.section]]![indexPath.row]
        let reuseIdentifier = String(format: "cell%i", abs(indexPath.row%2))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ContactListCell
        let u = contacts.filter { $0.contactHandle == handle }
        let trueContact = u.first!
        cell.configure(contact: trueContact)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure(contactListKeys[section])
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let handle: String = contactList[contactListKeys[indexPath.section]]![indexPath.row]
        let u: [Contact] = contacts.filter { $0.contactHandle == handle }
        guard let i = u.first else { print(u); fatalError() }
        performSegue(withIdentifier: "toCardIntro", sender: i)
    }
}

class ContactListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var presenceAndRatingView: PresenceAndRatingDisplay!
    
    func configure(contact: Contact) {
        nameLabel.text = contact.contactHandle
        presenceAndRatingView.contact = contact
    }
}
