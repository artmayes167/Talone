//
//  NeedWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

//import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

public class FirebaseGeneric {

    enum GenericFirebaseError: Error {
        case noAuthUser, alreadyTaken, alreadyOwned, unauthorized, undefined
        var errorDescription: String? {
            switch self {
            case .noAuthUser: return "No authenticated user"
            case .alreadyTaken: return "Name is already reserved by someone else"
            case .alreadyOwned: return "Name is already owned by the caller"
            case .unauthorized: return "User is not the creator of this document"
            case .undefined: return "Unspecified error"
            }
        }
    }

    struct AddressInfo: Codable {
        var streetAddress1: String
        var streetAddress2: String
        var zipCode: String
        var city: String
        var state: String?
        var country: String
    }

    struct GeographicCoordinates: Codable {
        var latitude: Double
        var longitude: Double

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public struct UserStub: Codable {
        var handle: String
        var uid: String
        var email: String
    }

    public struct LocationInfo: Codable {
        var city: String
        var state: String
        var country: String
        var address: AddressInfo?
        var geoLocation: GeographicCoordinates?

        init(locationInfo: LocationInfo) {
            self.city = locationInfo.city
            self.state = locationInfo.state
            self.country = locationInfo.country
            self.address = nil
            self.geoLocation = nil //GeographicCoordinates(latitude: coords.latitude!, longitude: coords.longitude!)
        }

        init(appLocationInfo: AppLocationInfo) {
            self.city = appLocationInfo.city!
            self.state = appLocationInfo.state!
            self.country = appLocationInfo.country!
            self.address = nil
            self.geoLocation = nil //GeographicCoordinates(latitude: coords.latitude!, longitude: coords.longitude!)
        }

        init(city: String, state: String, country: String = "USA", address: AddressInfo?, geoLocation: GeographicCoordinates?) {
            self.city = city
            self.state = state
            self.country = country
            self.address = address
            self.geoLocation = geoLocation
        }
    }
}

public class NeedsBase: FirebaseGeneric {

    public struct NeedItem: Identifiable, Codable {
        @DocumentID public var id: String? = UUID().uuidString
        var category: String // Inherited
        var headline: String?
        var description: String?
        var watchers: [UserStub]?
        var validUntil: Timestamp
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
        var locationInfo: LocationInfo
    }
}

public class NeedsDbWriter: NeedsBase {
    func addNeed(_ need: NeedItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("needs").document(need.id ?? "").setData(from: need)
        } catch {
            // handle the error here
            print(error)
            completion(error)
        }
        completion(nil)
    }

    /// Updates the description and headline of a given Need
    ///
    /// - Parameters:
    ///   - need:       `NeedsBase.NeedItem` FiB need item. Ensure that `description` field contains data. If `headline` is defined (not nil), it will be updated as well.
    /// - Returns:      On unsuccessful completion callback returns `Error`, otherwise nil.
    func updateNeedDescriptionAndHeadline(_ need: NeedsBase.NeedItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        guard let needId = need.id else { completion(GenericFirebaseError.undefined); return }

        let ref = db.collection("needs").document(needId)
        var data: [String: Any] = ["modifiedAt": FieldValue.serverTimestamp(),
                                    "description": need.description ?? "no description"]
        if let headline = need.headline { data["headline"] = headline }

        ref.updateData(data) { error in
            completion(error)
        }
    }

    func deleteNeed(id: String, userHandle: String, completion: @escaping (Error?) -> Void) {

        guard let _ = Auth.auth().currentUser?.uid else {
            completion(GenericFirebaseError.noAuthUser)
            return
        }

        let db = Firestore.firestore()
        db.collection("needs").document(id).delete { err in
            completion(err)
        }
    }

    /// Creates a link to a Need in Firebase. Users handle, user Id and email address are added to the Need watchers array.
    ///
    /// - Parameters:
    ///   - need:       `NeedsBase.NeedItem` FiB need item
    ///   - userHandle      User handle as string
    ///   - email                   Users associated email
    /// - Returns:      On unsuccessful completion returns `Error`.
    func watchNeed(_ need: NeedsBase.NeedItem, usingHandle userHandle: String, email: String, completion: @escaping (Error?) -> Void) {

        if let userId = Auth.auth().currentUser?.uid {
            associateAuthUserToNeed(id: need.id!, using: userHandle, userId: userId, email: email) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    /// Unlinks the user from a given Need in Firebase. Users handle, user Id and email address are added to the Need watchers array.
    ///
    /// - Parameters:
    ///   - need:       `NeedsBase.NeedItem` FiB need item
    ///   - userHandle      User handle as string
    ///   - email                   Users associated email
    /// - Returns:      On unsuccessful completion returns `Error`.
    func unwatchNeed(id needId: String, handle: String, email: String, completion: @escaping (Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("needs").document(needId)
            let data = ["uid": userId, "email": email, "handle": handle]
            ref.updateData(["watchers": FieldValue.arrayRemove([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }

    private func associateAuthUserToNeed(id needId: String, using handle: String, userId: String, email: String, completion: @escaping (Error?) -> Void) {
        if let _ = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let ref = db.collection("needs").document(needId)
            let data = ["uid": userId, "email": email, "handle": handle]
            ref.updateData(["watchers": FieldValue.arrayUnion([data]), "modifiedAt": FieldValue.serverTimestamp()]) { error in
                completion(error)
            }
        } else {
            completion(GenericFirebaseError.noAuthUser)
        }
    }
}
