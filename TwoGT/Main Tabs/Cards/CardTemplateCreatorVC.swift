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
    
    @IBOutlet weak var availableTableView: UITableView!
    @IBOutlet weak var addedTableView: UITableView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    
    private var addresses: [Address] {
        get {
            let adds =  AppDelegate.user.addresses
            return adds.sorted { return $0.type! < $1.type! }
        }
    }
    
    private var phoneNumbers: [PhoneNumber] {
        get {
            let phones =  AppDelegate.user.phoneNumbers
            return phones.sorted { return $0.title! < $1.title! }
        }
    }
    
    private var emails: [Email] {
        get {
            let ems =  AppDelegate.user.emails
            return ems.sorted { return $0.name! < $1.name! }
        }
    }
    
     // MARK: - Array Management
    var allPossibles: [NSManagedObject]?
    var allAdded: [NSManagedObject]?
    func setAllPossibles() {
        var arr: [NSManagedObject] = []
        let allArrays: [[NSManagedObject]] = [addresses, phoneNumbers, emails]
        for array in allArrays {
            for x in array {
                arr.append(x)
            }
        }
        allPossibles = arr
        allAdded = []
    }
    
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
        setAllPossibles()
        setDragAndDropDelegates()
    }
    
    func setDragAndDropDelegates() {
        availableTableView.dragDelegate = self
        availableTableView.dropDelegate = self
        addedTableView.dragDelegate = self
        addedTableView.dropDelegate = self

        availableTableView.dragInteractionEnabled = true
        addedTableView.dragInteractionEnabled = true
    }

    enum CardElementTypes: String, RawRepresentable {
        case address, phoneNumber, email
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CardTemplateCreatorVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case availableTableView:
            return allPossibles?.count ?? 0
        case addedTableView:
            return allAdded?.count ?? 0
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = tableView == availableTableView ? allPossibles : allAdded
        let object = array![indexPath.row]
        
        // Included switch statement, because other cells may be used if the format changes
        switch typeForClass(object.entity.name) {
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! TemplateCell
            guard let a = object as? Address else { fatalError() }
            cell.detailsLabel.text = a.type
            return cell
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phone") as! TemplateCell
            guard let p = object as? PhoneNumber else { fatalError() }
            cell.detailsLabel.text = p.title
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "address") as! TemplateCell
            guard let e = object as? Email else { fatalError() }
            cell.detailsLabel.text = e.name
            return cell
        }
    }
    
    func keyForDefiningAttribute(object: NSManagedObject) -> String {
        switch typeForClass(object.entity.name) {
        case .address:
            return "type"
        case .phoneNumber:
            return "title"
        case .email:
            return "name"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: YouHeaderCell.identifier) as! YouHeaderCell
        return cell.contentView
    }
}

extension CardTemplateCreatorVC: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let possibles = allPossibles, let added = allAdded else { fatalError() }
        let object: NSManagedObject = tableView == availableTableView ? possibles[indexPath.row] : added[indexPath.row]
        
        let carrier = ObjectCarrier(className: object.entity.name!, objectIdentifier: object.value(forKeyPath: keyForDefiningAttribute(object: object)) as! String)
            
        do {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: carrier, requiringSecureCoding: false) {
                let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
                return [UIDragItem(itemProvider: itemProvider)]
            }
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        var destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        // attempt to load strings from the drop coordinator
        coordinator.session.loadObjects(ofClass: ObjectCarrier.self) { items in
            // convert the item provider array to a string array or bail out
            guard let strings = items as? [ObjectCarrier] else { return }

            // create an empty array to track rows we've copied
            var indexPaths = [IndexPath]()

            // loop over all the strings we received
            for (carrier) in strings.enumerated() {
                // create an index path for this new row, moving it down depending on how many we've already inserted
                let indexPath = IndexPath(row: destinationIndexPath.row, section: destinationIndexPath.section)

                guard var a = self.allAdded, var p = self.allPossibles else { fatalError() }
                // insert the copy into the correct array
                if tableView == self.availableTableView {
                    for mo in a {
                        let z = self.typeForClass(mo.entity.name)
                        if z.rawValue == carrier.element.className.lowercased(), mo.value(forKeyPath: self.keyForDefiningAttribute(object: mo)) as! String == carrier.element.objectIdentifier {
                            p.insert(mo, at: indexPath.row)
                        }
                    }
                    
                } else {
                    for mo in p {
                        let z = self.typeForClass(mo.entity.name)
                        if z.rawValue == carrier.element.className.lowercased(), mo.value(forKeyPath: self.keyForDefiningAttribute(object: mo)) as! String == carrier.element.objectIdentifier {
                            a.insert(mo, at: indexPath.row)
                            return
                        }
                    }
                }

                // keep track of this new row
                indexPaths.append(indexPath)
            }

            // insert them all into the table view at once
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

class TemplateCell: UITableViewCell {
    @IBOutlet weak var detailsLabel: UILabel!
}

class Carrier: NSObject {
}

final class ObjectCarrier: Carrier, NSItemProviderWriting, NSItemProviderReading, Codable {
    
    enum CodingKeys: String, CodingKey {
        case className, objectIdentifier
    }
    
    var className: String
    var objectIdentifier: String
    
    init(className: String, objectIdentifier: String) {
        self.className = className
        self.objectIdentifier = objectIdentifier
    }
    
    required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            className = try values.decode(String.self, forKey: .className)
            objectIdentifier = try values.decode(String.self, forKey: .objectIdentifier)
        }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        //We know that we want to represent our object as a data type, so we'll specify that
        return [(kUTTypeData as String)]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            //Here the object is encoded to a JSON data object and sent to the completion handler
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    static var readableTypeIdentifiersForItemProvider: [String] {
        //We know we want to accept our object as a data representation, so we'll specify that here
        return [(kUTTypeData) as String]
    }
    
    //This function actually has a return type of Self, but that really messes things up when you are trying to return your object, so if you mark your class as final as I've done above, the you can change the return type to return your class type.
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ObjectCarrier {
        let decoder = JSONDecoder()
        do {
            //Here we decode the object back to it's class representation and return it
            let object = try decoder.decode(ObjectCarrier.self, from: data)
            return object
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

