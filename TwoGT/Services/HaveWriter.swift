//
//  HaveWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class HavesBase: FirebaseGeneric {
        
    struct HaveItem: Codable {
        @DocumentID var id: String? = UUID().uuidString
        var category: String
        var description: String?
        var needs: [String]? // Need Ids
        var users: [String]? // user.uids
        var validUntil: Timestamp?
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
    
    func associateNeedId(_ needId: String, withHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()        
        //do {
            let ref = db.collection("haves").document(haveId)
        ref.updateData(["needs": FieldValue.arrayUnion([needId])]) { error in
            print(error)
            completion(error)
        }
    }

    func associateUserId(_ userId: String, withHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("haves").document(haveId)
        ref.updateData(["interestedUsers": FieldValue.arrayUnion([userId])]) { error in
            print(error)
            completion(error)
        }
    }
    
    func associateAuthUserWithHaveId(_ haveId: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            ref.updateData(["interestedUsers": FieldValue.arrayUnion([userId])]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }
    
    func associateAuthUserHavingNeedId(_ needId: String, toHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            var data = ["uid": userId]
            data["need"] = needId
            ref.updateData(["interestedUsers": FieldValue.arrayUnion([data])]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }



}
