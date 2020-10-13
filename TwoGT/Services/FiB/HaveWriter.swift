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

public class HavesBase: FirebaseGeneric {

    public struct HaveItem: Codable {
        @DocumentID public var id: String? = UUID().uuidString
        var category: String
        var headline: String?
        var description: String?
        var needs: [NeedStub]?      // Need Ids, userIds and handles
        var validUntil: Timestamp?
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
        var locationInfo: LocationInfo
    }

    public struct NeedStub: Codable {
        var owner: String
        var id: String
        var createdBy: String

        enum CodingKeys: String, CodingKey { // example code to show how to handle differing attribute names.
            case owner = "handle"
            case createdBy = "uid"
            case id
        }
    }
}

public class HavesDbWriter: HavesBase {
    func addHave(_ have: HaveItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("haves").document(have.id ?? "").setData(from: have)
        } catch {
            print(error.localizedDescription  + "in HaveWriter -> addHave")
            completion(error)
        }
        completion(nil)
    }

    func associateNeedId(_ needId: String, withHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("haves").document(haveId)
        ref.updateData(["needs": FieldValue.arrayUnion([needId])]) { error in
            print(error.debugDescription + "in HaveWriter -> associateNeedId")
            completion(error)
        }
    }

    func associateUserId(_ userId: String, withHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("haves").document(haveId)
        ref.updateData(["needs": FieldValue.arrayUnion([userId])]) { error in
            print(error.debugDescription + "in HaveWriter -> associateUserId")
            completion(error)
        }
    }

    func associateAuthUserWithHaveId(_ haveId: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            ref.updateData(["needs": FieldValue.arrayUnion([userId])]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    func associateAuthUserHavingNeed(_ needItem: NeedsBase.NeedItem, toHaveId haveId: String, completion: @escaping (Error?) -> Void) {
        if let _ = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            let data = ["uid": needItem.createdBy, "id": needItem.id, "handle": needItem.owner]
            ref.updateData(["needs": FieldValue.arrayUnion([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    func disassociateAuthUserHavingNeedId(_ id: String, handle: String, fromHaveId: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(fromHaveId)
            let data = ["uid": userId, "id": id, "handle": handle]
            ref.updateData(["needs": FieldValue.arrayRemove([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    func deleteHave(id: String, creator: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(GenericFirebaseError.noAuthUser)
            return
        }

        if creator != userId {
            completion(GenericFirebaseError.unauthorized)
        }

        let db = Firestore.firestore()
        db.collection("haves").document(id).delete { err in
            completion(err)
        }
    }

}
