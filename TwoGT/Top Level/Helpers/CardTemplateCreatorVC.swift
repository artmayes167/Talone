//
//  CardTemplateCreatorVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import AlamofireImage

class CardTemplateCreatorVC: UIViewController {
    
    /// handles filtering and sorting as datasource
    var model = CardTemplateModel()
    
     // MARK: - UI
    @IBOutlet weak var availableTableView: UITableView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var plusImage: UIImageView!
    @IBOutlet weak var messageTextView: UITextView?
    
     // MARK: - Data
//    private var card: CardTemplate?
//    private var canEditTitle: Bool {
//        return true
//    }
    private var potentialImage: UIImage?
    
    private var contact: Contact? {
        didSet {
            if let c = contact, cardInstance == nil {
                cardInstance = c.sentCards?.last
            }
        }
    }
    
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
            guard let i = cardInstance else { return }
            CoreDataGod.managedContext.refresh(i, mergeChanges: true)
            model.set(card: i)
            if contact == nil {
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
    
//    func configure(card: CardTemplate?) {
//        self.card = card
//    }
    
    func configure(contact: Contact?, card: CardTemplateInstance?, haveItem: HavesBase.HaveItem?, needItem: NeedsBase.NeedItem?) {
        var satisfied = false
        if (contact != nil) {
            self.contact = contact
            satisfied = true
        }
        if (card != nil) {
            self.cardInstance = card
            satisfied = true
        }
        if (haveItem != nil) {
            self.haveItem = haveItem
            satisfied = true
        }
        if (needItem != nil) {
            self.needItem = needItem
            satisfied = true
        }
        if !satisfied { fatalError() }
    }
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        availableTableView.rowHeight = UITableView.automaticDimension
        availableTableView.estimatedRowHeight = 62
        
        let images = CoreDataImageHelper.shared.fetchAllImages()
        imageButton.isEnabled = true
        plusImage.isHidden = false
        if let i = images?.first?.image {
            potentialImage = i.af.imageAspectScaled(toFit: imageButton.bounds.size)
        }
        
        handleLabel.text = AppDelegateHelper.user.handle
        if let c = cardInstance {
            if let image = c.image {
                /// image has been previously added to template
                potentialImage = image.af.imageAspectScaled(toFit: imageButton.bounds.size)
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.setImage(potentialImage, for: .normal)
                imageButton.isSelected = true
                imageButton.isEnabled = true
            }
            titleTextField?.text = c.templateTitle
        }
        var contentInset: UIEdgeInsets = self.availableTableView.contentInset
        contentInset.bottom = contentInset.bottom + 50
        availableTableView.contentInset = contentInset
        availableTableView.reloadData()
        setDragAndDropDelegates()
    }
    
    func setDragAndDropDelegates() {
        availableTableView.dragDelegate = self
        availableTableView.dropDelegate = self
        availableTableView.dragInteractionEnabled = true
    }
    
    func typeForClass(_ c: String?) -> CardElementTypes {
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
    
    /// If there wasn't an image shown and included before, there is now-- and vice-versa
    @IBAction func touchedAddRemoveImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if potentialImage != nil {
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.setImage(potentialImage, for: .normal)
            } else {
                showOkayOrCancelAlert(title: "hmm", message: "no images have been set. would you like to add one?") { (_) in
                    self.changeImage(sender)
                } cancelHandler: { (_) in }
                imageButton.setImage(#imageLiteral(resourceName: "avatar.png"), for: .normal)
            }
        }
    }
    
    @IBAction func blockUser(_ sender: UIButton) {
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        /// Editing
        if let c = cardInstance {
            CoreDataGod.managedContext.refresh(c, mergeChanges: true)
            c.image = potentialImage ?? imageButton.image(for: .normal)
            let all = model.allAdded
            
            // remove addresses from object that have been removed
            for x in c.allAddresses() {
                if !all.contains(x) {
                    if let a = x as? Address {
                        c.removeFromAddresses(a)
                    } else if let p = x as? PhoneNumber {
                        c.removeFromPhoneNumbers(p)
                    } else if let e = x as? Email {
                        c.removeFromEmails(e)
                    }
                }
            }
            CoreDataGod.managedContext.refresh(c, mergeChanges: true)
            // add addresses to object that have been added
            for x in all {
                if !c.allAddresses().contains(x) {
                    if let a = x as? Address {
                        c.addToAddresses(a)
                    } else if let p = x as? PhoneNumber {
                        c.addToPhoneNumbers(p)
                    } else if let e = x as? Email {
                        c.addToEmails(e)
                    }
                }
            }
            CoreDataGod.managedContext.refreshAllObjects()
            CoreDataGod.save()
        } else { /// Creating
            let handle = contact!.contactHandle!
            let success =  CardTemplate.create(cardCategory: handle, image: potentialImage)
            if success {
                if let c = CoreDataGod.user.cardTemplates?.first(where: { $0.templateTitle == handle }) {
                    CoreDataGod.managedContext.refresh(c, mergeChanges: true)
                    let all = model.allAdded
                    for x in all {
                        if let a = x as? Address {
                            c.addToAddresses(a)
                        } else if let p = x as? PhoneNumber {
                            c.addToPhoneNumbers(p)
                        } else if let e = x as? Email {
                            c.addToEmails(e)
                        }
                    }
                    cardInstance = CardTemplateInstance.create(toHandle: handle, card: c)
                    CoreDataGod.managedContext.refreshAllObjects()
                }
            }
        }
        self.presentationController!.delegate!.updateUI()
        sendCard()
    }
    
    private func sendCard() {
        let data = GateKeeper().buildCodableInstanceAndEncode(instance: cardInstance!)
        // TODO: Move this logic to another utility class.
        let fibCard = CardsBase.FiBCardItem(createdBy: CoreDataGod.user.uid!, createdFor: contact!.contactUid!, payload: data.base64EncodedString(), owner: CoreDataGod.user.handle!)
        
        CardsDbWriter().addCard(fibCard) { [weak self] error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self?.view.makeToast("Successfully sent a card to " + (self?.contact!.contactHandle!)!) { [weak self] _ in
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

extension CardTemplateCreatorVC:  UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: messageTextView!, displayName: "message", initialText: messageTextView!.text)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

extension CardTemplateCreatorVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.allAdded.count
        default:
            return model.allPossibles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = indexPath.section == 0 ? model.allAdded : model.allPossibles
        let object = array[indexPath.row]
        
        // Included switch statement, because other cells may be used if the format changes
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
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        cell.configure(section == 0 ? "added": "available")
        return cell.contentView
    }
}

extension CardTemplateCreatorVC: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return model.dragItems(for: indexPath)
    }
    
    // MARK: - UITableViewDropDelegate
    
    /**
         Ensure that the drop session contains a drag item with a data representation
         that the view can consume.
    */
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return model.canHandle(session)
    }

    /**
         A drop proposal from a table view includes two items: a drop operation,
         typically .move or .copy; and an intent, which declares the action the
         table view will take upon receiving the items. (A drop proposal from a
         custom view does includes only a drop operation, not an intent.)
    */
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    /**
         This delegate method is the only opportunity for accessing and loading
         the data representations offered in the drag item. The drop coordinator
         supports accessing the dropped items, updating the table view, and specifying
         optional animations. Local drags with one item go through the existing
         `tableView(_:moveRowAt:to:)` method on the data source.
     
        Calls `model.addItem`, which processes the move and sets the corresponding array values
    */
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        var destinationIndexPath: IndexPath
//
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
                self.model.addItem(at: destinationIndexPath)
        
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [model.sourceIndexPath!], with: .automatic)
            tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        } completion: { (_) in
            tableView.reloadData()
        }
    }
}

extension CardTemplateCreatorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func changeImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        
        let aspectScaledToFitImage = userPickedImage.af.imageAspectScaled(toFit: CGSize(width: 150.0, height: 150.0))
        CoreDataImageHelper.shared.saveImage(aspectScaledToFitImage, fileName: "")
        showOkayAlert(title: "", message: "Image successfully saved", handler: nil)
        
        if let im: [ImageInfo] = CoreDataImageHelper.shared.fetchAllImages() {
            if let imageFromStorage = im.last?.image {
                let i = imageFromStorage.af.imageAspectScaled(toFit: imageButton.bounds.size)
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.setImage(i, for: .normal)
            }
            
        } else {
            view.makeToast("Image saving and rerendering failed")
            imageButton.setImage(userPickedImage, for: .normal)
        }
        picker.dismiss(animated: true)
    }
}
