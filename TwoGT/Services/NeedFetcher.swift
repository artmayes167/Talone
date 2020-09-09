//
//  NeedFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class NeedsDbFetcher: NeedsBase {
    func fetchNeeds(city: String, state: String, _ country: String?, completion: @escaping ([NeedItem]) -> Void) {
        let db = Firestore.firestore()

        db.collection("needs").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country ?? "USA")
            .getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                let needs = snapshot.documents.compactMap { (document) -> NeedItem? in
                    print(document)
                    var item: NeedItem?
                    do {
                        item = try document.data(as: NeedItem.self)
                    } catch {
                        print(error)
                    }
                    return item
                }
                completion(needs)
            }
        }
    }
}
