//
//  ViewMyTemplateVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class ViewMyTemplateVC: UIViewController {
    
    @IBOutlet weak var templateTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var card: Card? {
        didSet {
            if isViewLoaded {
                setCardData()
            }
        }
    }
    
    var cardAddresses: [NSManagedObject] = []
    
    func setCardData() {
        var arr: [NSManagedObject] = []
        if let c = card {
            let a: [CardAddress] = c.addresses
            let p: [CardPhoneNumber] = c.phoneNumbers
            let e: [CardEmail] = c.emails
            arr.append(contentsOf: a + p + e)
            templateTitleLabel.text = c.title
            handleLabel.text = c.userHandle
            
            if let i = c.image, let d = UIImage(data: i) {
                imageButton.setImage(d, for: .normal)
            } else {
                imageButton.setImage( #imageLiteral(resourceName: "avatar.png"), for: .normal)
            }
        }
        cardAddresses = arr
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCardData()
    }
    
    func typeForClass(_ c: String?) -> CardElementTypes {
        guard let name = c else { fatalError() }
        switch name {
        case CardAddress().entity.name:
            return .address
        case CardPhoneNumber().entity.name:
            return .phoneNumber
        case CardEmail().entity.name:
            return .email
        default:
            fatalError()
        }
    }
    
    @IBAction func edit(_ sender: UIButton) {
        // Nope
    }

    @IBAction func showUsersWithTemplate(_ sender: UIButton) {  // Interactions
        // Nope
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

extension ViewMyTemplateVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let object = cardAddresses[indexPath.row]
        
        // Included switch statement, because other cells may be used if the format changes
        switch typeForClass(object.entity.name) {
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! TemplateAddressCell
            guard let a = object as? CardAddress else { fatalError() }
            cell.detailsLabel.text = a.title
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phone") as! TemplatePhoneCell
            guard let p = object as? CardPhoneNumber else { fatalError() }
            cell.detailsLabel.text = p.title
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "email") as! TemplateEmailCell
            guard let e = object as? CardEmail else { fatalError() }
            cell.detailsLabel.text = e.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure("included contact info")
        return cell.contentView
    }
}
