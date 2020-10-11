//
//  YouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

enum AddressSections: Int, CaseIterable {
    case address, phoneNumber, email
}

@objc class YouVC: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var addresses: [Address] = []
    var phoneNumbers: [PhoneNumber] = []
    var emails: [Email] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func setInitialUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 62
        
        if let im = CoreDataImageHelper.shared.fetchAllImages() {
            if let imageFromStorage = im.first?.image {
                let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: imageButton.bounds.size)
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.setImage(i, for: .normal)
            }
        }
        
        handleLabel.text = CoreDataGod.user.handle
    }
    
    @IBAction @objc func changeImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func performSegueTo(_ section: AddressSections) {
        switch section {
        case .address:
            performSegue(withIdentifier: "toAddAddress", sender: nil)
        case .phoneNumber:
            performSegue(withIdentifier: "toAddPhoneNumber", sender: nil)
        case .email:
            performSegue(withIdentifier: "toAddEmail", sender: nil)
        }
    }
    
    @IBAction func unwindToYouVC( _ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}

extension YouVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddressSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AddressSections(rawValue: section) {
        case .address:
            if let adds = CoreDataGod.user.addresses { addresses = adds }
            return addresses.count
        case .phoneNumber:
            if let phones = CoreDataGod.user.phoneNumbers { phoneNumbers = phones }
            return phoneNumbers.count
        case .email:
            if let ems = CoreDataGod.user.emails { emails = ems }
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
            cell.configure(name: address.title, details: address.displayName())
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier(indexPath)) as! AddressCell
            let phoneNumber = phoneNumbers[indexPath.row]
            cell.configure(name: phoneNumber.title, details: phoneNumber.number)
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier(indexPath)) as! AddressCell
            let email = emails[indexPath.row]
            cell.configure(name: email.title, details: email.emailString)
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouFooterCell.identifier) as! YouFooterCell
        switch AddressSections(rawValue: section) {
        case .address:
            cell.configure(controller: self, selector: #selector(addNewAddress))
        case .phoneNumber:
            cell.configure(controller: self, selector: #selector(addNewPhoneNumber))
        case .email:
            cell.configure(controller: self, selector: #selector(addNewEmail))
        default:
            fatalError()
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let managedObjectContext = CoreDataGod.managedContext
        if editingStyle == .delete {
            switch AddressSections(rawValue: indexPath.section) {
            case .address:
                let a = addresses[indexPath.row]
                managedObjectContext.delete(a)
            case .phoneNumber:
                let p = phoneNumbers[indexPath.row]
                managedObjectContext.delete(p)
            case .email:
                let e = emails[indexPath.row]
                if e.title != DefaultsKeys.taloneEmail.rawValue {
                    managedObjectContext.delete(e)
                } else {
                    showOkayAlert(title: "Sorry", message: "Can't touch this email.  It's special.", handler: nil)
                    return // don't want to crash because we're deleting a row that shouldn't be
                }
            default:
                fatalError()
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Nope
        }
    }
    
    @objc func addNewAddress() {
        performSegueTo(.address)
    }
    @objc func addNewPhoneNumber() {
        performSegueTo(.phoneNumber)
    }
    @objc func addNewEmail() {
        performSegueTo(.email)
    }
}

 // MARK: - Custom Cells

class YouHeaderCell: UITableViewCell {
    static let identifier = "header"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(_ string: String) {
        titleLabel.text = string
    }
}

class YouFooterCell: UITableViewCell {
    static let identifier = "footer"
    
    @IBOutlet weak var addNewButton: DesignableButton!
    
    func configure(controller: YouVC, selector: Selector) {
        addNewButton.addTarget(controller, action: selector, for: .touchUpInside)
    }
}

class AddressCell: UITableViewCell {
    static func identifier(_ indexPath: IndexPath) -> String {
        print(String(format: "address%i", abs(indexPath.row%2)))
        return String(format: "address%i", abs(indexPath.row%2))
    }
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(name: String?, details: String?) {
        nameLabel.text = name == "taloneEmail" ? "secret" : name
        detailsLabel.text = details
    }
}

class EmailCell: UITableViewCell {
    static let identifier = "email"
    func configure() { }
}

class TelephoneNumberCell: UITableViewCell {
    static let identifier = "telephone"
    func configure() { }
}

extension YouVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        
        let aspectScaledToFitImage = userPickedImage.af.imageAspectScaled(toFit: CGSize(width: 120.0, height: 120.0))
        if let imageData = try? aspectScaledToFitImage.heicData(compressionQuality: 0.3) {
            CoreDataImageHelper.shared.saveImage(data: imageData)
            showOkayAlert(title: "", message: "Image successfully saved", handler: nil)
            
            if let im = CoreDataImageHelper.shared.fetchAllImages() {
                if let imageFromStorage = im.first?.image {
                    let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: imageButton.bounds.size)
                    imageButton.imageView?.contentMode = .scaleAspectFill
                    imageButton.setImage(i, for: .normal)
                }
                
            } else {
                view.makeToast("Image saving and rerendering failed")
                imageButton.setImage(userPickedImage, for: .normal)
            }
        }
        picker.dismiss(animated: true)
    }
}
