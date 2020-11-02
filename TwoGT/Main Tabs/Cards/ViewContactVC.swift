//
//  ViewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

/// Callers:
class ViewContactVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var templateTitleLabel: UILabel!
    @IBOutlet weak var notesView: UITextView!
    @IBOutlet weak var notesTitleLabel: UILabel?
    @IBOutlet weak var messageTitleLabel: UILabel?
    @IBOutlet weak var sendCardButton: DesignableButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var cardAddresses: [NSManagedObject] = [] {
        didSet { tableView.reloadData() }
    }
    
    private func typeForClass(_ c: String?) -> CardElementTypes {
        guard let name = c else { fatalError() }
        switch name {
        case Address().entity.name:
            return .address
        case PhoneNumber().entity.name:
            return .phoneNumber
        case Email().entity.name:
            return .email
        default:
            fatalError()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func call(number: String) {
        DispatchQueue.main.async {
            if let url = URL(string: String(format: "tel:%@", number)) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.showOkayAlert(title: "Can't Call".taloneCased(), message: "You're probably running this on an ipod.  Or they sent you a bogus number. Either way, this is not your moment.".taloneCased(), handler: nil)
                }
            } else {
                self.showOkayAlert(title: "", message: "Bad url".taloneCased(), handler: nil)
            }
        }
    }
    
    fileprivate func setCardAddresses(card c: CardTemplateInstance) {
        var allAdded: [NSManagedObject] = []
        if let adds = c.addresses {
            for a in adds {
                if let add = a as? Address { allAdded.append(add) }
            }
        }
        if let phones = c.phoneNumbers {
            for p in phones {
                if let ph = p as? PhoneNumber { allAdded.append(ph) }
            }
        }
        if let emails = c.emails {
            for e in emails {
                if let email = e as? Email { allAdded.append(email) }
            }
        }
        cardAddresses = allAdded
        tableView.reloadData()
    }
    
    func setCardData() {}
    func saveNotes(_ notes: String) {}
    func sendCard() {}
    
    func updateUIFor(card c: CardTemplateInstance) {
        CoreDataGod.managedContext.refresh(c, mergeChanges: true)
        handleLabel.text = c.userHandle
        templateTitleLabel.text = c.templateTitle
        messageTextView.text = c.message
        
        let image = c.image
        if let imageFromStorage = image {
            let i = imageFromStorage.af.imageAspectScaled(toFit: imageButton.bounds.size)
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.setImage(i, for: .normal)
        } else {
            let newImage = UIImage(named: "avatar")
            imageButton.setImage(newImage!, for: .normal)
        }
        view.layoutIfNeeded()
    }
    
    func updateUIFor(template c: CardTemplateInstance) {
        CoreDataGod.managedContext.refresh(c, mergeChanges: true)
        handleLabel.text = c.userHandle
        templateTitleLabel.text = c.templateTitle
        
        let image = c.image
        if let imageFromStorage = image {
            let i = imageFromStorage.af.imageAspectScaled(toFit: imageButton.bounds.size)
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.setImage(i, for: .normal)
        } else {
            let newImage = UIImage(named: "avatar")
            imageButton.setImage(newImage!, for: .normal)
        }
        view.layoutIfNeeded()
    }
}

class TheirContactVC: ViewContactVC {
    @IBOutlet weak var saveNotesButton: DesignableButton?
    
   @IBAction func saveNotes(_ sender: UIButton) {
       if let t = notesView.text?.pure() { saveNotes(t) }
   }
    
    private var theirCard: CardTemplateInstance? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    private var contact: Contact?
    
    func set(contact: Contact) {
        CoreDataGod.managedContext.refresh(contact, mergeChanges: true)
        self.contact = contact
        if let received = contact.receivedCards {
            if let r = received.last {
                CoreDataGod.managedContext.refresh(r, mergeChanges: true)
                theirCard = r
            }
        }
    }
    
    override func setCardData() {
        if let c = theirCard { setCardAddresses(card: c) }
    }
    
    // called by UIAdaptivePresentationControllerDelegate
    override func updateUI() {
        if let c = contact {
            set(contact: c)
            messageTextView.isEditable = false
            messageTextView.text = theirCard!.message
            notesView.isEditable = true
            notesView.text = theirCard!.personalNotes
            updateUIFor(card: theirCard!)
        }
    }
    
    override func saveNotes(_ notes: String) {
        guard let t = theirCard else { fatalError() }
        t.personalNotes = notes
        DispatchQueue.main.async {
            CoreDataGod.managedContext.refresh(t, mergeChanges: true)
            CoreDataGod.save()
            self.showOkayAlert(title: "".taloneCased(), message: "successfully saved notes".taloneCased(), handler: nil)
            self.updateUI()
        }
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRatings" {
            let vc = segue.destination as! RatingVC
            vc.configure(contact: contact!)
        }
    }
    
    override func updateUIFor(card c: CardTemplateInstance) {
        notesView.isHidden = false
        notesTitleLabel?.isHidden = false
        super.updateUIFor(card: c)
    }
}

class MyContactVC: ViewContactVC {
    private var myCard: CardTemplateInstance? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    private var contact: Contact?
    
    func set(contact: Contact) {
        CoreDataGod.managedContext.refresh(contact, mergeChanges: true)
        self.contact = contact
        if let sent = contact.sentCards {
            if let s = sent.last {
                CoreDataGod.managedContext.refresh(s, mergeChanges: true)
                myCard = s
            }
        }
    }
    
    // called by UIAdaptivePresentationControllerDelegate
    override func updateUI() {
        if let c = contact {
            set(contact: c)
            updateUIFor(card: myCard!)
        }
    }
    
    override func setCardData() {
        if let c = myCard { setCardAddresses(card: c) }
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        showCompleteAndSendCardHelper(contact: contact, card: myCard)
    }
    
    override func updateUIFor(card c: CardTemplateInstance) {
        CoreDataGod.managedContext.refresh(c, mergeChanges: true)
        notesView.isHidden = true
        notesTitleLabel?.isHidden = true
        if let m = myCard?.message, !m.isEmpty {
            messageTextView.isHidden = false
            messageTitleLabel?.isHidden = false
            messageTextView.text = m
        } else {
            messageTextView.isHidden = true
            messageTitleLabel?.isHidden = true
        }
        super.updateUIFor(card: c)
    }
    
    // MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "toRatings" {
            let vc = segue.destination as! RatingVC
            vc.configure(contact: contact!)
       }
   }
}

class MyTemplateVC: ViewContactVC {
    var instance: CardTemplateInstance? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    // called by UIAdaptivePresentationControllerDelegate
    override func updateUI() {
        if let m = instance { updateUIFor(template: m) }
    }
    
    override func setCardData() {
        if let c = instance { cardAddresses = c.allAddresses() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditTemplate" {
            let vc = segue.destination as! CardTemplateCreatorVC
            vc.configure(contact: nil, card: instance, haveItem: nil, needItem: nil)
        }
    }
}
    
extension ViewContactVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let object = cardAddresses[indexPath.row]
        
        switch typeForClass(object.entity.name) {
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! TemplateAddressCell
            let a = object as! Address
            cell.detailsLabel.text = a.title
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phone") as! TemplatePhoneCell
            let p = object as! PhoneNumber
            cell.detailsLabel.text = p.title
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "email") as! TemplateEmailCell
            let e = object as! Email
            cell.detailsLabel.text = e.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 20 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure("included contact info")
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self as? TheirContactVC {
            let object = cardAddresses[indexPath.row]
            
            switch typeForClass(object.entity.name) {
            case .email:
                guard let e = object as? Email else { return }
                launchEmail(to: [e.emailString!], body: "From \(CoreDataGod.user.handle!): ")
            case .phoneNumber:
                guard let p = object as? PhoneNumber else { return }
                call(number: p.number!)
            default:
                showOkayAlert(title: "sorry".taloneCased(), message: "teleportation is not available with this model.".taloneCased(), handler: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ViewContactVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == notesView {
            showTextViewHelper(textView: notesView, displayName: "personal notes", initialText: notesView.text)
            return false
        }
        if textView == messageTextView {
            showTextViewHelper(textView: messageTextView, displayName: "message", initialText: messageTextView.text)
            return false
        }
        return false
    }
}

