//
//  YouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

enum AddressSections: Int, CaseIterable {
    case address, phoneNumber, email
}

@objc class YouVC: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var addresses: [Address] {
        get {
            let adds =  AppDelegate.user.addresses
            let a = adds.sorted { return $0.title! < $1.title! }
            return a.filter { $0.entity.name != CardAddress().entity.name }
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegate.user.phoneNumbers
            let p = phones.sorted { return $0.title! < $1.title! }
            return p.filter { $0.entity.name != CardPhoneNumber().entity.name }
        }
    }
    
    private var emails: [Email] {
        get {
            let ems =  AppDelegate.user.emails
            let e = ems.sorted { return $0.title! < $1.title! }
            return e.filter { $0.entity.name != CardEmail().entity.name }
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

//    @IBSegueAction func toProfileView(_ coder: NSCoder) -> UIViewController? {
//        return UIHostingController(coder: coder, rootView: ContentView())
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
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
        imageButton.setImage(userPickedImage, for: .normal)
        
        if let imageData = userPickedImage.pngData() {
            CoreDataImageHelper.shareInstance.saveImage(data: imageData)
           }
        picker.dismiss(animated: true)
    }
}

class CoreDataImageHelper: NSObject {
    static let shareInstance = CoreDataImageHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImage(data: Data) {
        let imageInfo = ImageInfo(context: context)
        imageInfo.image = data
        imageInfo.type = "userImage"
        AppDelegate.user.addToImages(imageInfo)
        do {
            try context.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage() -> ImageInfo? {
        var fetchingImage = [ImageInfo]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageInfo")
        do {
            fetchingImage = try context.fetch(fetchRequest) as! [ImageInfo]
        } catch {
            print("Error while fetching the image")
        }
        return fetchingImage.first(where: { $0.type == "userImage" })
    }
}
