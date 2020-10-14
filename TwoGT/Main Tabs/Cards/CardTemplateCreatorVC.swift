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
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var plusImage: UIImageView!
    
    
     // MARK: - Data
    private var card: CardTemplate?
    private var canEditTitle: Bool {
        return card == nil
    }
    private var potentialImage: UIImage?
    
    func configure(card: CardTemplate?) {
        self.card = card
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
        
        
        if let c = card {
            model.set(card: c)
            
            if let image = c.image {
                /// image has been previously added to template
                potentialImage = image.af.imageAspectScaled(toFit: imageButton.bounds.size)
                imageButton.imageView?.contentMode = .scaleAspectFill
                imageButton.setImage(potentialImage, for: .normal)
                imageButton.isSelected = true
                imageButton.isEnabled = true
            }
            titleTextField.text = c.templateTitle
        } else {
            model.set(card: nil)
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
                showOkayOrCancelAlert(title: "hmm", message: "no images have been set. Would you like to add one?") { (_) in
                    self.changeImage(sender)
                } cancelHandler: { (_) in }
                imageButton.setImage(#imageLiteral(resourceName: "avatar.png"), for: .normal)
            }
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        if (titleTextField.text?.isEmpty ?? true) || (model.allAdded.isEmpty && imageButton.image(for: .normal) == #imageLiteral(resourceName: "avatar.png"))  {
            showOkayAlert(title: "Nope", message: "Add a title and some contact information. a default template with no information already exists for you, titled \(DefaultTitles.noDataTemplate.rawValue)", handler: nil)
            return
        }
        
        /// Editing
        if let c = card {
            
            c.templateTitle = titleTextField.text!.pure()
            c.image = potentialImage
            
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
            CoreDataGod.managedContext.refresh(c, mergeChanges: true)
        } else { /// Creating
            let c = CardTemplate.create(cardCategory: titleTextField.text!.pure(), image: potentialImage)
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
            CoreDataGod.managedContext.refresh(c, mergeChanges: true)
        }
        CoreDataGod.save()
        view.makeToast("Card created!".taloneCased()) { [weak self] _ in
            self?.performSegue(withIdentifier: "unwindToTemplates", sender: nil)
        }
    }
}

extension CardTemplateCreatorVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !canEditTitle {
            showOkayAlert(title: "Nope".taloneCased(), message: "you're stuck with this title, until I make it changeable. who's got the power, now, chump?".taloneCased(), handler: nil)
            return false
        }
        return true
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
