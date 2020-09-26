//
//  YouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/20/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

enum AddressSections: Int {
    case address, phoneNumber, email
}

@objc class YouVC: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var addresses: [Address] {
        get {
            guard let adds =  AppDelegate.user.addresses else { fatalError() }
            var allAdds: [Address] = []
            for a in adds {
                allAdds.append(a as! Address)
            }
            return allAdds.sorted { return $0.type! < $1.type! }
        }
    }
    
    var phoneNumbers: [PhoneNumber] {
        get {
            guard let phones =  AppDelegate.user.phoneNumbers else { fatalError() }
            var allPhones: [PhoneNumber] = []
            for p in phones {
                allPhones.append(p as! PhoneNumber)
            }
            return allPhones.sorted { return $0.title! < $1.title! }
        }
    }
    
    var emails: [Email] {
        get {
            guard let ems =  AppDelegate.user.emails else { fatalError() }
            var allEms: [Email] = []
            for e in ems {
                allEms.append(e as! Email)
            }
            return allEms.sorted { return $0.name! < $1.name! }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        let image = CoreDataImageHelper.shareInstance.fetchImage()
        var newImage: UIImage?
        if let i = image?.image {
            newImage = UIImage(data: i)
        } else {
            newImage = UIImage(named: "avatar")
        }
        imageButton.setImage(newImage!, for: .normal)
    }
    
    @IBAction @objc func changeImage() {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier) as! AddressCell
            let address = addresses[indexPath.row]
            cell.configure(name: address.type, details: address.displayName())
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier) as! AddressCell
            let phoneNumber = phoneNumbers[indexPath.row]
            cell.configure(name: phoneNumber.title, details: phoneNumber.number)
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.identifier) as! AddressCell
            let email = emails[indexPath.row]
            cell.configure(name: email.name, details: email.emailString)
            return cell
        default:
            fatalError()
        }
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
                managedObjectContext.delete(e)
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
    static let identifier = "address"
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(name: String?, details: String?) {
        nameLabel.text = name
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
