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
    
    private var interactions: [Interaction] = [] {
        didSet {
            var dict: [String: [String]] = [:]
            for i in interactions {
                if let s = i.referenceUserHandle, let firstChar = s.first {
                    if var array = dict[String(firstChar)] {
                        array.append(s)
                        print("in dict: %@, in array: %@", dict[String(firstChar)]!, array)
                    } else {
                        dict[String(firstChar)] = [s]
                    }
                } else { fatalError() }
            }
            contactList = dict
        }
    }
    
    private var contactList: [String: [String]] = [:] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    private var contactListKeys: [String] {
        get {
            return contactList.keys.sorted()
        }
    }
    
    private func getInteractions() {
        let i = AppDelegate.user.interactions
        if i.isEmpty { return }
        interactions = i
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("all contacts")
        getInteractions()
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


extension AllReceivedCardsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactListKeys.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactListKeys
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList[contactListKeys[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let handle = contactList[contactListKeys[indexPath.section]]![indexPath.row]
        let reuseIdentifier = String(format: "cell%i", abs(indexPath.row%2))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ContactListCell
        let u = interactions.filter { $0.referenceUserHandle == handle }
        cell.configure(handle: handle, image: u.first?.receivedCard?.image)
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
}

class ContactListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    func configure(handle: String, image: Data?) {
        nameLabel.text = handle
        if let i = image, let d = UIImage(data: i) {
            userImageView.image = d
        } else {
            userImageView.image = #imageLiteral(resourceName: "avatar.png")
        }
    }
}
