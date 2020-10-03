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
            var possibles: [String] = ["none"]
            var cards: [Card] = []
            
            let c = AppDelegate.user.cardTemplates ?? [] // [Card]
                
            if !c.isEmpty {
                cards = c.filter { $0.entity.name != CardTemplateInstance().entity.name }
            }
        
            let mappedTemplates = cards.isEmpty ? [] : cards.map { $0.title! }
            for t in mappedTemplates {
                if !(t == "") && !(t == "none") { possibles.append(t) }
            }
            
            return possibles.sorted()
        }
    }
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var templateTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var templateSelectionTableViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var haveItem: HavesBase.HaveItem?
    private var needItem: NeedsBase.NeedItem?
    private var interaction: Interaction? {
        didSet {
            if interaction == nil { return }
            guard let r = received else { fatalError() }
            relevantCard = r ? interaction?.receivedCard?.first : interaction?.sentCard?.first
        }
    }
    
    private var received: Bool?
    
    private var relevantCard: CardTemplateInstance?
    
    func configure(received: Bool? = nil, interaction: Interaction? = nil, haveItem: HavesBase.HaveItem? = nil, needItem: NeedsBase.NeedItem? = nil) {
        self.received = received
        self.interaction = interaction
        self.haveItem = haveItem
        self.needItem = needItem
        if isViewLoaded {
            configure()
        }
    }
    
    private func getRecipientUid() -> String? {
        return haveItem?.createdBy ?? needItem?.createdBy ?? relevantCard?.uid
    }
    private func getRecipientHandle() -> String? {
        return haveItem?.owner ?? needItem?.owner ?? interaction?.referenceUserHandle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let handle = getRecipientHandle() else { fatalError() }
        headerTitleLabel.text = "new card to \(handle)"
        templateTextField.text = "none"
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        continueOrAlertWithRecipientUid()
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
    
    private func continueOrAlertWithRecipientUid() {
        /// check id
        guard let recipientUid = getRecipientUid() else {
            /// No id
            showOkayOrCancelAlert(title: "careful", message: "this is an old card, so it will crash the app.  proceed anyway?", okayHandler: { _ in
                self.sendCard(card: nil, nil)
            }, cancelHandler: nil)
            return
        }
        if let c = checkTemplate(id: recipientUid) {
            sendCard(card: c, recipientUid)
        }
    }
    
    private func checkTemplate(id: String) -> Card? {
        // If no template has been selected
        if !(templateTextField.text == "none") {
            let cards: [Card] = AppDelegate.user.cardTemplates!
            let filteredCards = cards.isEmpty ? [] : cards.filter { $0.title == templateTextField.text }
            if !filteredCards.isEmpty {
                return filteredCards.first
            }
        } else {
            showOkayOrCancelAlert(title: "notice", message: "You have chosen 'none', which will functionally erase all the contact details the other person has.  if this is what you want, hit okay.", okayHandler: { (_) in
                self.sendCard(card: nil, id)
            }, cancelHandler: nil)
        }
        return nil
    }

    private func sendCard(card c: Card?, _ receiverUid: String?) {
        guard let recipientUid = receiverUid else { fatalError() }
        
        // Already checked for existing category
        let card = c == nil ? CardTemplateInstance.create(cardCategory: "none", notes: "Nope", image: nil) : c
        // Now we have a card template, or nothing
        
        let handle = AppDelegate.user.handle!
        let myUid = AppDelegate.user.uid!
        guard let recipientHandle = getRecipientHandle() else { fatalError() }
        let cardInstance = CardTemplateInstance.create(card: card, codableCard: nil, fromHandle: handle, toHandle: recipientHandle, message: messageTextView.text.pure())
        let data = GateKeeper().buildCodableInstanceAndEncode(instance: cardInstance)
        // TODO: Move this logic to another utility class.
        let fibCard = CardsBase.FiBCardItem(createdBy: myUid, createdFor: recipientUid, payload: data.base64EncodedString(), owner: handle)
        
        CardsDbWriter().addCard(fibCard) { error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.view.makeToast("Successfully sent a card to \(recipientHandle)") { [weak self] _ in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! SavedLocationCell
        cell.titleLabel.text = templates[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        templateTextField.text = templates[indexPath.row]
        templateSelectionTableViewContainer.isHidden = true
        view.layoutIfNeeded()
    }
}
