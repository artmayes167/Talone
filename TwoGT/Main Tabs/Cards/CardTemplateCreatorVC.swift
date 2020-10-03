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
    private var card: Card?
    private var canEditTitle: Bool {
        return card == nil
    }
    
    func configure(card: Card?) {
        self.card = card
    }
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        availableTableView.rowHeight = UITableView.automaticDimension
        availableTableView.estimatedRowHeight = 62
        
        let image = CoreDataImageHelper.shareInstance.fetchImage()
        if let _ = image?.image {
            imageButton.isEnabled = true
            plusImage.isHidden = false
        } else {
            imageButton.isEnabled = false
            plusImage.isHidden = true
        }
        
        handleLabel.text = AppDelegate.user.handle
        
        
        if let c = card {
            model.set(card: c)
            
            
            if let image = c.image {
                if let i = UIImage(data: image) {
                    imageButton.setImage(i, for: .normal)
                    imageButton.isSelected = true
                    imageButton.isEnabled = true
                }
            }
            titleTextField.text = c.title ?? ""
        } else {
            model.set(card: nil)
        }
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
        case Address().entity.name, CardAddress().entity.name:
            return .address
        case PhoneNumber().entity.name, CardPhoneNumber().entity.name:
            return .phoneNumber
        case Email().entity.name, CardEmail().entity.name:
            return .email
        default:
            fatalError()
        }
    }
    
    /// If there wasn't an image shown and included before, there is now-- and vice-versa
    @IBAction func touchedAddRemoveImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let image = CoreDataImageHelper.shareInstance.fetchImage()
            if let i = image?.image {
                if let z = UIImage(data: i) {
                    let resized = z.af.imageAspectScaled(toFill: imageButton.bounds.size)
                    imageButton.setImage(resized, for: .normal)
                }
                
            }
        } else {
            imageButton.setImage(#imageLiteral(resourceName: "avatar.png"), for: .normal)
        }
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        
        if (titleTextField.text?.isEmpty ?? true) || (model.allAdded?.isEmpty ?? true) {
            showOkayAlert(title: "Nope", message: "Add a title and some contact information", handler: nil)
            return
        }
        
        /// get the image if user has chosen to use it
        var imageData: Data?
        if imageButton.isSelected {
            guard let i = imageButton.image(for: .normal) else {
                fatalError()
            }
            let aspectScaledToFitImage = i.af.imageAspectScaled(toFit: CGSize(width: 28.0, height: 28.0))
            imageData = aspectScaledToFitImage.jpegData(compressionQuality: 0.3)
        }
        
        /// Editing
        if let c = card {
            
            c.title = titleTextField.text!
            c.image = imageData
            
            if let all = model.allAdded {
                for x in all {
                    switch x.entity.name {
                    case Address().entity.name:
                        CardAddress.create(title: c.title!, address: x as? Address)
                    case PhoneNumber().entity.name:
                        CardPhoneNumber.create(title: c.title!, phoneNumber: x as? PhoneNumber)
                    case Email().entity.name:
                        CardEmail.create(title: c.title!, email: x as? Email)
                    default:
                        print("------------ Old entity in All Added:" + x.entity.name!)
                    }
                }
            }
            
            /// and remove the old added if they were removed
            for x in model.allPossibles! {
                switch x.entity.name {
                case CardAddress().entity.name:
                    let z =  x as! CardAddress
                    z.title = nil
                    z.uid = nil
                case CardPhoneNumber().entity.name:
                    let z =  x as! CardPhoneNumber
                    z.title = nil
                    z.uid = nil
                case CardEmail().entity.name:
                    let z =  x as! CardEmail
                    z.title = nil
                    z.uid = nil
                default:
                    print("------------ Same old entity in All Added:" + x.entity.name!)
                }
            }
            
        } else { /// Not editing
            card = Card.create(cardCategory: titleTextField.text!.pure(), notes: nil, image: imageData)
            
            if let all = model.allAdded {
                for x in all {
                    switch x.entity.name {
                    case Address().entity.name:
                        CardAddress.create(title: card!.title!, address: x as? Address)
                    case PhoneNumber().entity.name:
                        CardPhoneNumber.create(title: card!.title!, phoneNumber: x as? PhoneNumber)
                    case Email().entity.name:
                        CardEmail.create(title: card!.title!, email: x as? Email)
                    default:
                        print("------------ Old entity in All Added:" + x.entity.name!)
                    }
                }
            }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        do {
            appDelegate.persistentContainer.viewContext.processPendingChanges()
            try appDelegate.persistentContainer.viewContext.save()
            view.makeToast("Card created!")
            performSegue(withIdentifier: "unwindToTemplates", sender: nil)
        } catch {
            fatalError()
        }
    }
}

extension CardTemplateCreatorVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !canEditTitle {
            showOkayAlert(title: "Nope", message: "you're stuck with this title, until I make it changeable. who's got the power, now, chump?", handler: nil)
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
            return model.allAdded!.count
        default:
            return model.allPossibles!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = indexPath.section == 0 ? model.allAdded : model.allPossibles
        let object = array![indexPath.row]
        
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

