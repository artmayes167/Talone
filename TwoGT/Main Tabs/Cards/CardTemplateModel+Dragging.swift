/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helper methods for providing and consuming drag-and-drop data.
*/

import UIKit
import MobileCoreServices

extension CardTemplateModel {
    /**
         A helper function that serves as an interface to the data model,
         called by the implementation of the `tableView(_ canHandle:)` method.
    */
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /**
         A helper function that serves as an interface to the data mode, called
         by the `tableView(_:itemsForBeginning:at:)` method.
    */
    mutating func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let added = allAdded, let possibles = allPossibles else { fatalError() }
        let object = indexPath.section == 0 ? added[indexPath.row] : possibles[indexPath.row]
        moveStarted(with: object, indexPath: indexPath)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false) //object.data(using: .utf8)
            let itemProvider = NSItemProvider()
            
            itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
                completion(data, nil)
                return nil
            }

            return [
                UIDragItem(itemProvider: itemProvider)
            ]
        } catch {
            print("----------Failed to archive object!")
            fatalError()
        }
    }
}
