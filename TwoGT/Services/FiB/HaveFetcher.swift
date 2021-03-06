//
//  HaveFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol HavesObserver {
    func observeMyHaves(completion: @escaping ([HavesBase.HaveItem]) -> Void)
    func stopObserving()
}

class HavesDbFetcher: HavesBase, HavesObserver {
    var listener: ListenerRegistration?

    func observeMyHaves(completion: @escaping ([HavesBase.HaveItem]) -> Void) {
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        listener = db.collection("haves").whereField("createdBy", isEqualTo: uid)
            .addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }

                for diff in snapshot.documentChanges {
                    if diff.type == .modified {
                        print("modified have: \(diff.document.data())")
                    }
                }

                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
                let haves = snapshot.documents.compactMap { (document) -> HaveItem? in
                    print(document)
                    var item: HaveItem?
                    do {
                        item = try document.data(as: HaveItem.self)
                    } catch {
                        print(error)
                    }
                    return item
                }
                completion(haves)
            }
    }

    func stopObserving() {
        listener?.remove()
    }

    func fetchHaves(matching needs: [String], _ city: String, _ state: String, _ country: String, completion: @escaping ([HaveItem], Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("haves").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country)
            .whereField("category", in: needs.map { $0.taloneDatabaseValue() })
            //.whereField("createdBy", isLessThan: "")
            .getDocuments { (snapshot, error) in
            if let error = error {
                completion([], error)
            } else if let snapshot = snapshot {
                let haves = snapshot.documents.compactMap { (document) -> HaveItem? in
                    print(document)
                    var item: HaveItem?
                    do {
                        item = try document.data(as: HaveItem.self)
                    } catch {
                        print(error)
                    }
                    return item
                }
                completion(haves, nil)
            }
        }
    }

    func fetchAllHaves(city: String, _ state: String, _ country: String, maxCount: Int, completion: @escaping ([HaveItem], Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("haves").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country)
            .limit(to: maxCount)
            .order(by: "modifiedAt", descending: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion([], error)
                } else if let snapshot = snapshot {
                    let haves = snapshot.documents.compactMap { (document) -> HaveItem? in
                        var item: HaveItem?
                        do {
                            item = try document.data(as: HaveItem.self)
                        } catch {
                            print(error)
                        }
                        return item
                    }
                    completion(haves, nil)
                }
            }
    }
    
    func fetchHave(id: String, completion: @escaping (HaveItem?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("haves").document(id).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                var item: HaveItem?
                do {
                    item = try document.data(as: HaveItem.self)!
                } catch {
                    completion(nil, error)
                    return
                }
                completion(item, nil)
            }
        }
    }

// Currently Unused code:
//    func fetchMyHaves(_ completion: @escaping ([HaveItem]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let db = Firestore.firestore()
//
//        db.collection("haves").whereField("createdBy", isEqualTo: uid)
//            .getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error)
//            } else if let snapshot = snapshot {
//                let haves = snapshot.documents.compactMap { (document) -> HaveItem? in
//                    print(document)
//                    var item: HaveItem?
//                    do {
//                        item = try document.data(as: HaveItem.self)
//                    } catch {
//                        print(error)
//                    }
//                    return item
//                }
//                completion(haves)
//            }
//        }
//    }
}
