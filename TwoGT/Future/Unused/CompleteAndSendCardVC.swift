//
//  CompleteAndSendCardVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/1/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

/// Will need to pass in uid when we do a send from search
class CompleteAndSendCardVC: UIViewController {
    
    private var templates: [String] {
        get {
            var possibles: [String] = []
            var cards: [CardTemplate] = []
            
            let c = CoreDataGod.user.cardTemplates ?? [] // [Card]
                
            if !c.isEmpty {
                cards = c.filter { $0.entity.name != CardTemplateInstance().entity.name }
            }
        
            let mappedTemplates = cards.isEmpty ? [] : cards.map { $0.templateTitle! }
            for t in mappedTemplates {
                possibles.append(t)
            }
            
            return possibles.sorted()
        }
    }
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var templateSelectionTableViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var haveItem: HavesBase.HaveItem? {
        didSet {
            if let h = haveItem {
                /// see if there's a contact associated with the haveItem
                if let c = CoreDataGod.user.contacts?.filter ({ $0.contactHandle == h.owner }) {
                    if !c.isEmpty {
                        contact = c.first
                        return
                    }
                }
                contact = Contact.create(newPersonHandle: h.owner, newPersonUid: h.createdBy)
            }
        }
    }
    private var needItem: NeedsBase.NeedItem? {
        didSet {
            if let n = needItem {
                /// see if there's a contact associated with the haveItem
                if let c = CoreDataGod.user.contacts?.filter ({ $0.contactHandle == n.owner }) {
                    if !c.isEmpty {
                        contact = c.first
                        return
                    }
                }
                contact = Contact.create(newPersonHandle: n.owner, newPersonUid: n.createdBy)
            }
        }
    }
    private var cardInstance: CardTemplateInstance? {
        didSet {
            if let i = cardInstance {
                // check if a received card, and get
                if let c = CoreDataGod.user.contacts?.filter ({ $0.contactUid == i.uid }), !c.isEmpty  {
                    contact = c.first
                    return
                    // check if a sent card, and get
                } else if let c = CoreDataGod.user.contacts?.filter ({ $0.contactHandle == i.receiverUserHandle }), !c.isEmpty {
                    contact = c.first
                    return
                } else {
                    fatalError()
                }
            }
        }
    }
    
    private var contact: Contact? // this should be set, no matter what
    
    func configure(card: CardTemplateInstance? = nil, haveItem: HavesBase.HaveItem? = nil, needItem: NeedsBase.NeedItem? = nil) {
        if card == nil && haveItem == nil && needItem == nil { fatalError() }
        self.cardInstance = card
        self.haveItem = haveItem
        self.needItem = needItem
        if isViewLoaded {
            updateUI()
        }
    }
    
    private func getRecipientUid() -> String {
        return contact!.contactUid!
    }
    
    private func getRecipientHandle() -> String {
        return contact!.contactHandle!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func updateUI() {
        let handle = getRecipientHandle()
        headerTitleLabel.text = "new card to \(handle)"
//        templateTextField.text =
//            contact?.sentCards?.first?.templateTitle ?? CoreDataGod.user.cardTemplates!.first!.templateTitle
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        if templateTextField.text == "no data" {
            showOkayOrCancelAlert(title: "no data template".taloneCased(), message: "this template is designed to be used to communicate without disclosing any data about yourself, except your handle. Sending someone this template will effectively block them from communicating with you.  use it wisely.".taloneCased()) { (_) in
                self.sendCard()
            } cancelHandler: { (_) in }

        } else {
            sendCard()
        }
    }
    
    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func templateNamed(_ name: String) -> CardTemplate {
        guard let temps = CoreDataGod.user.cardTemplates else { fatalError() }
        let t = temps.filter { $0.templateTitle == name }
        return t.first!
    }
    
    private func buildTemplate() -> CardTemplateInstance {
        let t = templateNamed(templateTextField.text!)
        return CardTemplateInstance.create(toHandle: getRecipientHandle(), card: t, message: messageTextView.text.pure())
        
    }

    private func sendCard() {
        let cardInstance = buildTemplate()
        let data = GateKeeper().buildCodableInstanceAndEncode(instance: cardInstance)
        // TODO: Move this logic to another utility class.
        let fibCard = CardsBase.FiBCardItem(createdBy: CoreDataGod.user.uid!, createdFor: getRecipientUid(), payload: data.base64EncodedString(), owner: CoreDataGod.user.handle!)
        
        CardsDbWriter().addCard(fibCard) { error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.view.makeToast("Successfully sent a card to \(self.getRecipientHandle())") { [weak self] _ in
                    if let nav = self?.navigationController {
                        nav.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension CompleteAndSendCardVC: UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == templateTextField {
            templateSelectionTableViewContainer.isHidden = false
            tableView.reloadData()
            view.layoutIfNeeded()
            return false
        }
        return true
    }
}

extension CompleteAndSendCardVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = String(format: "cell%i", indexPath.row%2)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! TemplateNameCell
        cell.titleLabel.text = templates[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        templateTextField.text = templates[indexPath.row]
        templateSelectionTableViewContainer.isHidden = true
        view.layoutIfNeeded()
    }
}

class TemplateNameCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
