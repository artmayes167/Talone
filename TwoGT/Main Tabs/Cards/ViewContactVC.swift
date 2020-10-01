//
//  ViewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class ViewContactVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var messageTextView: InactiveTextView!
    @IBOutlet weak var notesView: ActiveTextView!
    @IBOutlet weak var saveNotesButton: DesignableButton!
    @IBOutlet weak var sendCardButton: DesignableButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var dataSource: InteractionDataSource? {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    var card: CardTemplateInstance? {
        didSet {
            setCardData()
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
        }
        cardAddresses = arr
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        // Strings are formatted in dataSource `ContactTabBarController`
        handleLabel.text = dataSource?.getHandle()
        notesView.text = dataSource?.getNotes()
        messageTextView.text = dataSource?.getMessage(sender: false)
        card = dataSource?.allContactInfo()
        let hasOld = dataSource?.previouslySentCard() ?? false
        sendCardButton.isEnabled = !hasOld
        
        let image = card?.image
        var newImage: UIImage?
        if let i = image {
            newImage = UIImage(data: i)
        } else {
            newImage = UIImage(named: "avatar")
        }
        imageButton.setImage(newImage!, for: .normal)
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
    
    
    
     // MARK: - IBActions
    @IBAction func saveNotes(_ sender: UIButton) {
        if let t = notesView.text?.pure() {
            dataSource?.saveNotes(t)
        }
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        // TODO: - Show card creation view, with template selector and message textView
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

extension ViewContactVC: UITableViewDelegate, UITableViewDataSource {
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
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure("included contact info")
        return cell.contentView
    }
}

extension ViewContactVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
        let s = UIStoryboard.init(name: "Helper", bundle: nil)
        guard let vc = s.instantiateViewController(identifier: "TextView Helper") as? TextViewHelperVC else { fatalError() }
        vc.configure(textView: textView, displayName: "personal notes", initialText: notesView.text)
        present(vc, animated: true, completion: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
}


