//
//  ViewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

/// Callers:
class ViewContactVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var messageTextView: InactiveTextView!
    @IBOutlet weak var templateTitleLabel: UILabel!
    @IBOutlet weak var notesView: ActiveTextView!
    @IBOutlet weak var saveNotesButton: DesignableButton!
    @IBOutlet weak var sendCardButton: DesignableButton!
    @IBOutlet weak var imageButton: UIButton!
    
    private var received: Bool?
    
    private var interaction: Interaction? {
        didSet {
            if let r = received {
                if let i = r ? interaction!.receivedCard?.first : interaction!.sentCard?.first {
                    /// crash if I fucked up
                    cardInstance = i
                }
            }
        }
    }
    
    /// Only looking at the template
    private var cardTemplate: Card? {
        didSet {
            if isViewLoaded {
                setCardData()
            }
        }
    }
    
    /// Looking at sent card, or received card
    private var cardInstance: CardTemplateInstance? {
        didSet {
            if isViewLoaded {
                setCardData()
            }
        }
    }
    
    private var cardAddresses: [NSManagedObject] = []
    
    
    /// If
    func configure(received: Bool? = nil, interaction: Interaction? = nil, template: Card? = nil) {
        if received == nil && interaction == nil && template == nil { fatalError() }
        
        if let r = received {
            self.received = r
            self.interaction = interaction
        } else {
            self.cardTemplate = template
        }
    }
    
    private func setCardData() {
        if let c = cardInstance ?? cardTemplate {
            let a: [CardAddress] = c.addresses
            let p: [CardPhoneNumber] = c.phoneNumbers
            let e: [CardEmail] = c.emails
            cardAddresses = a + p + e
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardData()
        updateUI()
    }
    
    private func updateUI() {
        // Strings are formatted in dataSource `ContactTabBarController`
        handleLabel.text = getRelevantHandle()
        notesView.text = getNotes()
        templateTitleLabel.text = interaction == nil ? cardTemplate?.title : cardInstance?.title
        messageTextView.text = interaction == nil ? cardTemplate?.comments : cardInstance?.comments
        notesView.text = interaction == nil ? cardTemplate?.personalNotes : cardInstance?.personalNotes
        
        let image = interaction == nil ? cardTemplate?.image : cardInstance?.image
        if let imageFromStorage = image {
            let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: imageButton.bounds.size)
            imageButton.imageView?.contentMode = .scaleAspectFill
            imageButton.setImage(i, for: .normal)
        } else {
            let newImage = UIImage(named: "avatar")
            imageButton.setImage(newImage!, for: .normal)
        }
    }
    
    private func typeForClass(_ c: String?) -> CardElementTypes {
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
    
    /// Go to the template selector, if we have templates
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
        
        showCompleteAndSendCardHelper(received: received, interaction: interaction)
        
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditTemplate" {
            guard let vc = segue.destination as? CardTemplateCreatorVC else { fatalError() }
            vc.configure(card: cardTemplate)
        }
    }
}

extension ViewContactVC {
    func getRelevantHandle() -> String {
        // If an interaction has not been created yet, it is because we are viewing a template
        let i = interaction == nil ?  cardTemplate?.userHandle! : interaction?.referenceUserHandle!
        return i! // should crash only if we fucked up
    }
    func getNotes() -> String {
        return interaction == nil ? "" : cardInstance?.personalNotes ?? ""
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


