//
//  RatingsHandler.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 10/25/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class RatingsDbHandler: FirebaseGeneric {

//    struct Ratings: Codable {
//        var uid: String                 // User Id of the owner of the handle.
//        var ratings: [String: Double]?
//        var score: Double
//    }

    private struct _Ratings: Codable {
        var ratings: [String: Double]?
        @ServerTimestamp var modifiedAt: Timestamp?
        var score: Double
    }

    /**
      Call this method to give a rating to any user. The score is stored in FiB, and each user can give only one score to each other user. Any time this method is called, the previous score of
        the current user is updated. User cannot downplay another user by calling this method numerous times.
        - Parameter uid: uid of the user being rated
        - Parameter score: Score as double between 0.0 - 1.0
        - Parameter raterHandle: Optional handle of the user giving the rating. (currently not used)
     */
    class func rateUser(uid: String, score: Double, raterHandle: String? = nil, raterEmail: String? = nil, completion: @escaping (Error?) -> Void) -> Error? {
        let db = Firestore.firestore()
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return GenericFirebaseError.noAuthUser }

        let ref = db.collection("userRatings").document(uid)
        
        var totalScore = -1.0
        ref.getDocument { (document, error) in
            if error == nil {
                totalScore = calculateUpdatedRatings(document, currentUserUid, score)
            }
            ref.updateData(["ratings.\(currentUserUid)": score, "modifiedAt": FieldValue.serverTimestamp(), "score": totalScore]) { error in
                if error?._code == 5 { // No document exists, create one.
                    ref.setData(["ratings": [currentUserUid: score], "modifiedAt": FieldValue.serverTimestamp(), "score": score], merge: true)
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        }

        return nil
    }

    /**
        Fetch the rating score for a given user. The scoring is between 0 and 1.0 (although this is not limited in the database in any manner).
        - Parameter uid: FiB uid string of the user whose score needs to be fetched from FiB.
        - Parameter completion:    In success, returns the score as Double; otherwise an error and -1.0 */
    class func fetchRating(uid : String, completion: @escaping (Double, Error?) -> Void) {

        let db = Firestore.firestore()

        let docRef = db.collection("userRatings").document(uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                completion(-1.0, error)
            } else if let document = document, document.exists {
                // TODO: Unfortunately Firestore doesn't allow us to limit the fields to score field only.
                // So, FiB forces us to download all fields of the document; thus all rating values will be downloaded (unnecessarily).
                // We can read the score value as is, no need to recalculate that.
                var item: _Ratings
                do {
                    item = try document.data(as: _Ratings.self)!
                } catch {
                    completion(-1.0, error)
                    return
                }
                completion(item.score, nil)
            }
        }
    }
    
    private class func calculateUpdatedRatings(_ document: DocumentSnapshot?, _ uid: String, _ score: Double) -> Double {
        if let document = document, document.exists {
            var item: _Ratings

            do {
                item = try document.data(as: _Ratings.self)!
            } catch {
                return -1.0
            }
            // add or update user's score to total score
            item.ratings![uid] = score
            let score = item.ratings!.count > 0 ? (item.ratings!.reduce(0.0) {$0 + Double($1.value)} / Double(item.ratings!.count)) : -1.0
            return score
        }
        return -1.0
    }
}
