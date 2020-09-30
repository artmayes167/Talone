//
//  CardFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/30/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class CardsBase: FirebaseGeneric {

    struct FiBCardItem: Codable {
        @DocumentID var id: String? = UUID().uuidString
        var createdBy: String
        var createdFor: String
        var payload: String
        var validUntil: Timestamp?
        var owner: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
    }
}

class CardsFetcher: CardsBase {

    class func observeCardsSentToMe(completion: @escaping ([FiBCardItem]) -> Void) {
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("cards").whereField("createdFor", isEqualTo: uid)
            .addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }

                for diff in snapshot.documentChanges {
                    if diff.type == .modified {
                        print("modified card: \(diff.document.data())")
                    }
                }

                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
                let cards = snapshot.documents.compactMap { (document) -> FiBCardItem? in
                    print(document)
                    var item: FiBCardItem?
                    do {
                        item = try document.data(as: FiBCardItem.self)
                    } catch {
                        print(error)
                    }
                    return item
                }
                completion(cards)
            }
    }
}
