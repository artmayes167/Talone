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

class FirebaseGeneric {

    enum GenericFirebaseError: Error {
        case noAuthUser, unauthorized, undefined
        var errorDescription: String? {
            switch self {
                case .noAuthUser: return "No authenticated user"
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

    struct LocationInfo: Codable {
        var city: String
        var state: String
        var country: String
        var address: AddressInfo?
        var geoLocation: GeographicCoordinates?

        init(locationInfo: AppLocationInfo) {
            self.city = locationInfo.city ?? ""
            guard let s = locationInfo.state, let c = locationInfo.country else { fatalError() }
            self.state = s
            self.country = c
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

class NeedsBase: FirebaseGeneric {

    struct NeedItem: Identifiable, Codable {
        @DocumentID var id: String? = UUID().uuidString
        var category: String // Inherited
        var headline: String?
        var description: String?
        var validUntil: Timestamp
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
        var locationInfo: LocationInfo
    }

}

class NeedsDbWriter: NeedsBase {
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

    func createNeedAndJoinHave(_ have: HavesBase.HaveItem, usingHandle userHandle: String, completion: @escaping (Error?, NeedItem?) -> Void) {

        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        if let userId = Auth.auth().currentUser?.uid {
            // TODO: This needsItem needs to derive data from MarketPlaceVC, as user may have entered description/header etc.
            let description = have.description
            let needItem = NeedsBase.NeedItem(category: have.category, headline: have.headline, description: description, validUntil: defaultValidUntilDate, owner: userHandle, createdBy: userId, locationInfo: have.locationInfo)

            addNeed(needItem) { error in
                if error == nil, let needId = needItem.id, let haveId = have.id {
                    HavesDbWriter().associateAuthUserHavingNeedId(needId, toHaveId: haveId) { error in
                        // call completion
                        completion(error, needItem)
                    }
                }
            }
        } else {
            completion(GenericFirebaseError.noAuthUser, nil)
        }
    }

    func deleteNeed(id: String, creator: String, associatedHaveId: String? = nil, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(GenericFirebaseError.noAuthUser)
            return
        }

        if creator != userId {
            completion(GenericFirebaseError.unauthorized)
        }

        let db = Firestore.firestore()
        db.collection("needs").document(id).delete { err in
            if let haveId = associatedHaveId {
                HavesDbWriter().disassociateAuthUserHavingNeedId(id, fromHaveId: haveId) { error in
                    // call completion
                    completion(error)
                }
            } else {
                completion(err)
            }
        }
    }
}
