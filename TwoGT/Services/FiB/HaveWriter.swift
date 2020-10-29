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
        var category: String { didSet {
            category = category.taloneDatabaseValue()
        } }
        var headline: String?
        var description: String?
        var watchers: [UserStub]?
        var validUntil: Timestamp?
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
        var locationInfo: LocationInfo
    }

}

public class HavesDbWriter: HavesBase {
    func addHave(_ have: HavesBase.HaveItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("haves").document(have.id ?? "").setData(from: have)
        } catch {
            print(error.localizedDescription  + "in HaveWriter -> addHave")
            completion(error)
            return
        }
        completion(nil)
    }

    /// Updates the description and headline of a given Have
    ///
    /// - Parameters:
    ///   - have:       `HavesBase.HaveItem` FiB have item. Ensure that `description` field contains data. If `headline` is defined (not nil), it will be updated as well.
    /// - Returns:      On unsuccessful completion callback returns `Error`, otherwise nil.
    func updateHaveDescriptionAndHeadline(_ have: HavesBase.HaveItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        guard let haveId = have.id else { completion(GenericFirebaseError.undefined); return }

        let ref = db.collection("haves").document(haveId)
        var data: [String: Any] = ["modifiedAt": FieldValue.serverTimestamp(),
                                    "description": have.description ?? "no description"]
        if let headline = have.headline { data["headline"] = headline }

        ref.updateData(data) { error in
            completion(error)
        }
    }

    /// Creates a link to a Have in Firebase. Users handle, user Id and email address are added to the Have watchers array.
    ///
    /// - Parameters:
    ///   - have:       `HavesBase.HaveItem` FiB have item
    ///   - userHandle      User handle as string
    ///   - email                   Users associated email
    /// - Returns:      On unsuccessful completion returns `Error`.
    func watchHave(_ have: HavesBase.HaveItem, usingHandle userHandle: String, email: String, completion: @escaping (Error?) -> Void) {

        if let userId = Auth.auth().currentUser?.uid {
            HavesDbWriter().associateAuthUserToHave(id: have.id!, using: userHandle, userId: userId, email: email) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    /// Unlinks the user from a given Have in Firebase. Users handle, user Id and email address are added to the Have watchers array.
    ///
    /// - Parameters:
    ///   - haveId:     HaveId  for the Have item in Firebase
    ///   - userHandle     User handle as string
    ///   - email                 Users associated email
    /// - Returns:      On unsuccessful completion returns `Error`.
    func unwatchHave(id haveId: String, handle: String, email: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            let data = ["uid": userId, "email": email, "handle": handle]
            ref.updateData(["watchers": FieldValue.arrayRemove([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    private func associateAuthUserToHave(id haveId: String, using handle: String, userId: String, email: String, completion: @escaping (Error?) -> Void) {
        if let _ = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("haves").document(haveId)
            let data = ["uid": userId, "email": email, "handle": handle]
            ref.updateData(["watchers": FieldValue.arrayUnion([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
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
