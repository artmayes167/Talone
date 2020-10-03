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

class CardTemplateCreatorVC: UIViewController {
    
    var model = CardTemplateModel()
    
    @IBOutlet weak var availableTableView: UITableView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        availableTableView.rowHeight = UITableView.automaticDimension
        availableTableView.estimatedRowHeight = 62
        
        let image = CoreDataImageHelper.shareInstance.fetchImage()
        var newImage: UIImage?
        if let i = image?.image {
            newImage = UIImage(data: i)
        } else {
            newImage = UIImage(named: "avatar")
        }
        imageButton.setImage(newImage!, for: .normal)
        handleLabel.text = AppDelegate.user.handle
        model.configure()
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
    
    @IBAction func touchedAddRemoveImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func save(_ sender: UIButton) {
        
        if (titleTextField.text?.isEmpty ?? true) || (model.allAdded?.isEmpty ?? true) {
            showOkayAlert(title: "Nope", message: "Add a title and some contact information", handler: nil)
            return
        }
        
        var imageData: Data?
        if addImageButton.isSelected {
            let image = CoreDataImageHelper.shareInstance.fetchImage()
            if let i = image?.image {
                imageData = i
            }
        }
        
        let c = Card.create(cardCategory: titleTextField.text!.pure(), notes: nil, image: imageData)
        
        for x in model.allAdded! {
            switch x.entity.name {
            case Address().entity.name:
                CardAddress.create(title: c.title!, address: x as? Address)
            case PhoneNumber().entity.name:
                CardPhoneNumber.create(title: c.title!, phoneNumber: x as? PhoneNumber)
            case Email().entity.name:
                CardEmail.create(title: c.title!, email: x as? Email)
            default:
                fatalError()
            }
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        do {
            try appDelegate.persistentContainer.viewContext.save()
            view.makeToast("Card created!")
            performSegue(withIdentifier: "unwindToTemplates", sender: nil)
        } catch {
            fatalError()
        }
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

