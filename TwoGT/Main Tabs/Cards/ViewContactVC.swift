//
//  ViewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

protocol InteractionDataSource {
    /// Universal, at Interaction level
    func getHandle() -> String
    /// Only for received card
    func getNotes() -> String // TODO: - work on formatting
    func allContactInfo() -> CardTemplateInstance?
    func getMessage(sender: Bool) -> String
    func saveNotes(_ notes: String)
}

class ViewContactVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var messageTextView: InactiveTextView!
    @IBOutlet weak var notesView: ActiveTextView!
    @IBOutlet weak var saveNotesButton: DesignableButton!
    @IBOutlet weak var sendCardButton: DesignableButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var interaction: Interaction?
    
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
        }
        cardAddresses = arr
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardData()
        updateUI()
    }
    
    func updateUI() {
        // Strings are formatted in dataSource `ContactTabBarController`
        handleLabel.text = getHandle()
        notesView.text = getNotes()
        messageTextView.text = getMessage(sender: false)
        card = allContactInfo()
        
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
            saveNotes(t)
        }
    }
    
    @IBAction func manageDataShare(_ sender: UIButton) {
        
        guard let temps = AppDelegate.user.cardTemplates else {
            showOkayAlert(title: "", message: "Please add a template") { _ in
                self.performSegue(withIdentifier: "unwindToTemplates", sender: nil)
            }
            return
        }
        
        if temps.isEmpty {
            showOkayAlert(title: "", message: "Please add a template") { _ in
                self.performSegue(withIdentifier: "unwindToTemplates", sender: nil)}
            return
        }
        
        showCompleteAndSendCardHelper(interaction: interaction)
        
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toTextViewHelper" {
//            guard let vc = segue.destination as? TextViewHelperVC else { fatalError() }
//            vc.configure(textView: notesView, displayName: "personal notes", initialText: notesView.text)
//        }
//    }
}

extension ViewContactVC: InteractionDataSource {
    func getHandle() -> String {
        let i = interaction == nil ?  card?.userHandle! : interaction?.referenceUserHandle!
        return i! // should crash only if we fucked up
    }
    func getNotes() -> String {
        return interaction?.receivedCard?.first?.personalNotes ?? ""
    }
    func allContactInfo() -> CardTemplateInstance? {
        return interaction?.receivedCard?.first
    }
    
    func getMessage(sender: Bool) -> String {
        return sender ? (interaction?.cardTemplate?.first?.comments ?? "") : (interaction?.receivedCard?.first?.comments ?? "")
    }
    func saveNotes(_ notes: String) {
        interaction?.receivedCard?.first?.personalNotes = notes
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
            let context = appDelegate.persistentContainer.viewContext
            _ = try? context.save()
        }
    }
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
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure("included contact info")
        return cell.contentView
    }
}

extension ViewContactVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: notesView, displayName: "personal notes", initialText: notesView.text)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
}


