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
    @IBOutlet weak var sendCardButton: DesignableButton!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBAction func manageDataShare(_ sender: UIButton) {
        sendCard()
    }
    
    var cardAddresses: [NSManagedObject] = [] {
        didSet {
            tableView.reloadData()
        }
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
        setCardData()
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
                if let add = a as? Address {
                    allAdded.append(add)
                }
            }
        }
        if let phones = c.phoneNumbers {
            for p in phones {
                if let ph = p as? PhoneNumber {
                    allAdded.append(ph)
                }
            }
        }
        if let emails = c.emails {
            for e in emails {
                if let email = e as? Email {
                    allAdded.append(email)
                }
            }
        }
        cardAddresses = allAdded
        updateUI()
    }
    
    func setCardData() {}
    func saveNotes(_ notes: String) {}
    func updateUI() {}
    func sendCard() {}
    
    func updateUIFor(card c: CardTemplateInstance) {
        handleLabel.text = c.userHandle
        templateTitleLabel.text = c.templateTitle
        messageTextView.text = c.message
        if notesView.isEditable {
            notesView.isHidden = false
            notesTitleLabel?.isHidden = false
        } else {
            notesView.isHidden = true
            notesTitleLabel?.isHidden = true
        }
        
        let image = c.image
        if let imageFromStorage = image {
            let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: imageButton.bounds.size)
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.setImage(i, for: .normal)
        } else {
            let newImage = UIImage(named: "avatar")
            imageButton.setImage(newImage!, for: .normal)
        }
        view.layoutIfNeeded()
    }
    
    func updateUIFor(template c: CardTemplate) {
        handleLabel.text = c.userHandle
        templateTitleLabel.text = c.templateTitle
        
        let image = c.image
        if let imageFromStorage = image {
            let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: imageButton.bounds.size)
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
    
    // MARK: - IBActions
   @IBAction func saveNotes(_ sender: UIButton) {
       if let t = notesView.text?.pure() {
           saveNotes(t)
       }
   }
    
    var theirCard: CardTemplateInstance? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    var contact: Contact?
    
    override func setCardData() {
        if let c = theirCard {
            setCardAddresses(card: c)
        }
    }
        
    override func updateUI() {
        if let t = theirCard {
            messageTextView.isEditable = false
            notesView.isEditable = true
            notesView.text = t.personalNotes
            updateUIFor(card: t)
        }
    }
    
    override func saveNotes(_ notes: String) {
        theirCard!.personalNotes = notes
        DispatchQueue.main.async {
            _ = try? CoreDataGod.managedContext.save()
            self.showOkayAlert(title: "".taloneCased(), message: "successfully saved notes".taloneCased(), handler: nil)
        }
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRatings" {
            if let vc = segue.destination as? RatingVC {
                if let c = contact {
                    vc.configure(contact: c)
                }
                
            }
        }
    }
}

class MyContactVC: ViewContactVC {
    
    var myCard: CardTemplateInstance? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    var contact: Contact?
    
    override func updateUI() {
        if let m = myCard {
            messageTextView.isEditable = true
            notesView.isEditable = false
            updateUIFor(card: m)
        }
    }
    
    override func setCardData() {
        if let c = myCard {
            setCardAddresses(card: c)
        }
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        showCompleteAndSendCardHelper(card: myCard)
    }
    
    // MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "toRatings" {
           if let vc = segue.destination as? RatingVC {
               if let c = contact {
                   vc.configure(contact: c)
               }
               
           }
       }
   }
}

class MyTemplateVC: ViewContactVC {
    
    @IBAction func editCard(_ sender: UIButton) {
        
    }
    
    var template: CardTemplate? {
        didSet { if isViewLoaded { setCardData() } }
    }
    
    override func updateUI() {
        if let m = template {
            updateUIFor(template: m)
        }
    }
    
    override func setCardData() {
        if let c = template {
            cardAddresses = c.allAddresses()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditTemplate" {
            guard let vc = segue.destination as? CardTemplateCreatorVC else { fatalError() }
            vc.configure(card: template)
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
            guard let a = object as? Address else { fatalError() }
            cell.detailsLabel.text = a.title
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phone") as! TemplatePhoneCell
            guard let p = object as? PhoneNumber else { fatalError() }
            cell.detailsLabel.text = p.title
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "email") as! TemplateEmailCell
            guard let e = object as? Email else { fatalError() }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self as? TheirContactVC {
            let object = cardAddresses[indexPath.row]
            
            switch typeForClass(object.entity.name) {
            case .email:
                guard let e = object as? Email else { return }
                launchEmail(to: e.emailString)
            case .phoneNumber:
                guard let p = object as? PhoneNumber else { return }
                call(number: p.number)
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

// MARK: -
extension ViewContactVC: MFMailComposeViewControllerDelegate {
   func launchEmail(to recipient: String) {
        let toRecipents = [recipient]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setToRecipients(toRecipents)
        self.present(mc, animated: true, completion: nil)
   }

   func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
       var message = ""
       switch result {
       case .cancelled:
           message = "Mail cancelled"
       case .saved:
           message = "Mail saved"
       case .sent:
           message = "Mail sent"
       case .failed:
           message = "Mail sent failure: \(String(describing: error?.localizedDescription))."
       default:
           message = "Something unanticipated has occurred"
           break
       }
       self.dismiss(animated: true) {
        self.showOkayAlert(title: "", message: message.taloneCased(), handler: nil)
       }
   }
}

