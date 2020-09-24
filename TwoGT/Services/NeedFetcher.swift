//
//  NeedFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseAuth
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

    func fetchNeed(id: String, completion: @escaping (NeedItem?) -> Void) {
        let db = Firestore.firestore()

        db.collection("needs").whereField("id", isEqualTo: id)
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
                    completion(needs.count > 0 ? needs[0] : nil)
                }
            }
    }

    // Convenience function
    func fetchMyNeeds(city: String, state: String, _ country: String?, since: Date? = nil, completion: @escaping ([NeedItem]) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            fetchUserNeeds(userId: userId, city: city, state: state, country, since: since, completion: completion)
         }
    }

    // NOTE: FOLLOWING QUERY REQUIRES COMPOSITE INDEX WHICH CURRENTLY IS MISSING.
    // Consider if this query is required. We can have certain amount of composite indexes, that's fine.
    // Index can be created:
    // https://console.firebase.google.com/v1/r/project/talone-23f99/firestore/indexes?create_composite=Ckpwcm9qZWN0cy90YWxvbmUtMjNmOTkvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL25lZWRzL2luZGV4ZXMvXxABGg0KCWNyZWF0ZWRCeRABGhUKEWxvY2F0aW9uSW5mby5jaXR5EAEaGAoUbG9jYXRpb25JbmZvLmNvdW50cnkQARoWChJsb2NhdGlvbkluZm8uc3RhdGUQARoNCgljcmVhdGVkQXQQARoMCghfX25hbWVfXxAB
    func fetchUserNeeds(userId: String, city: String, state: String, _ country: String?, since: Date? = nil, completion: @escaping ([NeedItem]) -> Void) {
        let db = Firestore.firestore()
        var sinceEpoch = 0

        if since != nil { sinceEpoch = Int(since?.timeIntervalSince1970 ?? 0 * 1000) }

        db.collection("needs").whereField("createdBy", isEqualTo: userId)
            .whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country ?? "USA")
            .whereField("createdAt", isGreaterThan: sinceEpoch)
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
