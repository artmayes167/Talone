//
//  CardTemplateCreatorVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import MobileCoreServices

class CardTemplateCreatorVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    
    private var addresses: [Address] {
        get {
            let adds =  AppDelegate.user.addresses
            return adds.sorted { return $0.type! < $1.type! }
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegate.user.phoneNumbers
            return phones.sorted { return $0.title! < $1.title! }
        }
    }
    
    private var emails: [Email] {
        get {
            let ems =  AppDelegate.user.emails
            return ems.sorted { return $0.name! < $1.name! }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 62
        
        let image = CoreDataImageHelper.shareInstance.fetchImage()
        var newImage: UIImage?
        if let i = image?.image {
            newImage = UIImage(data: i)
        } else {
            newImage = UIImage(named: "avatar")
        }
        imageButton.setImage(newImage!, for: .normal)
        
        handleLabel.text = AppDelegate.user.handle
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

extension CardTemplateCreatorVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddressSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AddressSections(rawValue: section) {
        case .address:
            return addresses.count
        case .phoneNumber:
            return phoneNumbers.count
        case .email:
            return emails.count
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Included switch statement, because other cells may be used if the format changes
        switch AddressSections(rawValue: indexPath.section) {
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier(indexPath)) as! AddressCell
            let address = addresses[indexPath.row]
            cell.configure(name: address.type, details: address.displayName())
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier(indexPath)) as! AddressCell
            let phoneNumber = phoneNumbers[indexPath.row]
            cell.configure(name: phoneNumber.title, details: phoneNumber.number)
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier(indexPath)) as! AddressCell
            let email = emails[indexPath.row]
            cell.configure(name: email.name, details: email.emailString)
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        var str = ""
        switch AddressSections(rawValue: section) {
        case .address:
           str = "physical addresses"
        case .phoneNumber:
            str = "phone numbers"
        case .email:
            str = "email addresses"
        default:
            fatalError()
        }
        cell.configure(str)
        return cell.contentView
    }
    
    
    
}



