//
//  HaveFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class HavesDbFetcher: HavesBase {
    func fetchHaves(matching needs: [String], _ city: String, _ state: String, _ country: String,  completion: @escaping ([HaveItem]) -> Void) {
        let db = Firestore.firestore()

        db.collection("haves").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country)
            .whereField("category", in: needs)
            .getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
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
                completion(haves)
            }
        }
    }
    
    func fetchAllHaves(in city: String, _ state: String, _ country: String,  completion: @escaping ([HaveItem]) -> Void) {
        let db = Firestore.firestore()

        db.collection("haves").whereField("locationInfo.city", isEqualTo: city)
            .whereField("locationInfo.state", isEqualTo: state)
            .whereField("locationInfo.country", isEqualTo: country)
            .getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
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
                completion(haves)
            }
        }
    }

}
