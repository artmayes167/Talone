//
//  HaveWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class HavesBase: FirebaseGeneric {
    
    struct HaveItem: Codable {
        @DocumentID var id: String? = UUID().uuidString
        var category: String
        var description: String?
        var validUntil: Int?
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        var locationInfo: LocationInfo
    }
}

class HavesDbWriter: HavesBase {
    func addHave(_ have: HaveItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("haves").document().setData(from: have)
        } catch {
            // handle the error here
            print(error)
            completion(error)
        }
        completion(nil)
    }
}
