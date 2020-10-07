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

    func fetchNeedsFor(category: String, city: String, state: String, country: String?, maxCount: Int, filterOutThisUser: Bool, completion: @escaping ([NeedItem], Error?) -> Void) {
        let db = Firestore.firestore()

        var t = db.collection("needs").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country ?? "USA")
            .limit(to: maxCount)
        if category.lowercased() != "any" {
            t = t.whereField("category", isEqualTo: category.capitalized)
        }
// TODO: Firestore issue
// As of Oct 6, 2020, Firestore has an issue that it REQUIRES result set be
// ordered by the same field where inequality filtering was used. We WOULD LIKE to use
// whereField("createdBy") isNotEqualTo: uid), but there's a limitation. We can't order the results by
// modifiedAt -timestamp. We need to fetch current User's needs as well and filter them out manually before
// providing them to UI code. However, in our case, since we limit the query, we want to receive the latest needs
// (as oldest needs may be already outdated. Ordering by "CreatedBy" field would result in some old Needs as well.
//        if let uid = Auth.auth().currentUser?.uid, filterOutThisUser {
//            t = t.whereField("createdBy", isNotEqualTo: uid)
//        }
//         t.order(by: "createdBy", descending: true)

        t.order(by: "modifiedAt", descending: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print(error)
                    completion([], error)
                } else if let snapshot = snapshot {
                    var needs = snapshot.documents.compactMap { (document) -> NeedItem? in
                        var item: NeedItem?
                        do {
                            item = try document.data(as: NeedItem.self)
                        } catch {
                            print(error)
                        }
                        return item
                    }
                    if let uid = Auth.auth().currentUser?.uid {
                        needs = needs.filter { $0.createdBy != uid }
                    }
                    completion(needs, nil)
                }
            }
    }
// CODE CURRENTLY NOT IN USE:
//    func fetchNeed(id: String, completion: @escaping (NeedItem?, Error?) -> Void) {
//        let db = Firestore.firestore()
//
//        db.collection("needs").whereField("id", isEqualTo: id)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    completion(nil, error)
//                } else if let snapshot = snapshot {
//                    let needs = snapshot.documents.compactMap { (document) -> NeedItem? in
//                        var item: NeedItem?
//                        do {
//                            item = try document.data(as: NeedItem.self)
//                        } catch {
//                            print(error)
//                        }
//                        return item
//                    }
//                    completion(needs.count > 0 ? needs[0] : nil, error)
//                }
//            }
//    }

// CODE CURRENTLY NOT IN USE:
    // Convenience function
//    func fetchMyNeeds(city: String, state: String, _ country: String?, since: Date? = nil, completion: @escaping ([NeedItem]) -> Void) {
//        if let userId = Auth.auth().currentUser?.uid {
//            fetchUserNeeds(userId: userId, city: city, state: state, country, since: since, completion: completion)
//         }
//    }
//
//    // NOTE: FOLLOWING QUERY REQUIRES COMPOSITE INDEX WHICH CURRENTLY IS MISSING.
//    // Consider if this query is required. We can have certain amount of composite indexes, that's fine.
//
//    func fetchUserNeeds(userId: String, city: String, state: String, _ country: String?, since: Date? = nil, completion: @escaping ([NeedItem]) -> Void) {
//        let db = Firestore.firestore()
//        var sinceEpoch = 0
//
//        if since != nil { sinceEpoch = Int(since?.timeIntervalSince1970 ?? 0 * 1000) }
//
//        db.collection("needs").whereField("createdBy", isEqualTo: userId)
//            .whereField("locationInfo.city", isEqualTo: city)
//            .whereField("locationInfo.state", isEqualTo: state)
//            .whereField("locationInfo.country", isEqualTo: country ?? "USA")
//            .whereField("createdAt", isGreaterThan: sinceEpoch)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print(error)
//                } else if let snapshot = snapshot {
//                    let needs = snapshot.documents.compactMap { (document) -> NeedItem? in
//                        print(document)
//                        var item: NeedItem?
//                        do {
//                            item = try document.data(as: NeedItem.self)
//                        } catch {
//                            print(error)
//                        }
//                        return item
//                    }
//                    completion(needs)
//                }
//            }
//    }
}
