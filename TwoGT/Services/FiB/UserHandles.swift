//
//  UserHandles.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 10/2/20.
//  Copyright © 2020 Jyrki Hoisko. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserHandlesDbHandler: FirebaseGeneric {

    struct UserHandle: Codable {
        var name: String                // Handle's visual description, e.g. "-NightHawk-"
        var locationInfo: LocationInfo? // Primary location where this handle is associated to
        var community: String?          // Potential community this user belongs to
        var uid: String?                 // User Id of the owner of the handle.
    }

    private struct _UserHandle: Codable {
        var ownerUid: String?
        var name: String
        var lowercase: String
        var locationInfo: LocationInfo?
        var community: String?
    }

    private var _cache = [_UserHandle]()
    var searchTerm = ""

    /**
        Registers given user handle to backend. User handle can contain special chars but it will be trimmed for white spaces.  This method can work offline, and it does
     not ensure there is no duplicates. That call the calling application logic needs to do separately (and decide how to handle offline-mode registrations
        - Parameter UserHandle: Struct containing UserHandle data*/
    class func registerUserHandle(_ hd: UserHandle) -> Error? {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return GenericFirebaseError.noAuthUser }

        let h = _UserHandle(name: hd.name.trimmingCharacters(in: .whitespacesAndNewlines),
                            lowercase: hd.name.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).lowercased(),
                            locationInfo: hd.locationInfo, community: hd.community)
        do {
            try db.collection("users").document(hd.uid ?? uid).setData(from: h)
        } catch {
            print(error.localizedDescription  + " in \(#function)")
            return error
        }
        return nil
    }

    /**
        Registers given user handle to backend. User handle can contain special chars but it will be trimmed for white spaces.  Method will first check if the handle is
        already registered (returns error if is). Because of the requirement to ensure uniqueness of the handle, this method needs internet connection.
        - Parameter hd: Struct containing UserHandle data.
        - Parameter completion: Completion handler that will be called with nil upon successful operation. If user handle is already reserved by current user, returning GenericFirebaseError.alreadyOwned. If handle is reserved by someone else, returning GenericFirebaseError.alreadyTaken.
        - Parameter Error: nil if succesful, otherwise GenericFirebaseError*/
    class func registerUserHandleAndCheckUniqueness(_ hd: UserHandle, completion: @escaping (Error?) -> Void) -> Error? {
        let db = Firestore.firestore()

        // Check if duplicate found.
        db.collection("users").whereField("name", isEqualTo: hd.name.trimmingCharacters(in: .whitespacesAndNewlines))
            .limit(to: 1)
            .getDocuments { [self] (snapshot, error) in
                if let error = error {
                    completion(error)
                } else if let snapshot = snapshot {
                    if snapshot.documents.count > 0 {
                        let userId = Auth.auth().currentUser?.uid
                        if snapshot.documents.count == 1 && snapshot.documents[0].documentID == userId {
                            completion(GenericFirebaseError.alreadyOwned)
                        } else {
                            completion(GenericFirebaseError.alreadyTaken)
                        }
                    } else {
                        completion(registerUserHandle(hd))
                    }
                }
            }
        return nil
    }

    /**
        Fetches stored User Handles from Firestore. This function can be called in rapid successions. It uses cache and it will return subsequent fetches from cache if result set is less than maxCount and previous fetch was successfully made, and new search query is continuation to previous one. (e.g. user typing "nig" -> "nigh" -> "night"
        - Parameter string: Partial or complete user-typed characters of handle to search. Will be trimmed and lowercased for backend search. Only alphanumeric characters are used for matching.
        - Parameter maxCount:   Maximum number of result objects returned
        - Parameter community:  Community name as string (optional)
        - Parameter completion:    returns an array of UserHandle structs (maxCount).*/
    func fetchUserHandles(startingWith string: String, maxCount: Int, community: String? = nil, completion: @escaping ([UserHandle]) -> Void) {

        let str = string.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).lowercased()

        // Check if we have this cached, and there is no way server can provide better results.
        if _cache.count < maxCount && str.starts(with: searchTerm) && searchTerm.count > 0 {
            print("\(#function) avoiding unnecessary backend call!")
            searchTerm = str
            _cache = _cache.filter { $0.lowercase.starts(with: str) }
            let handles = _cache.compactMap { UserHandle(name: $0.name, locationInfo: $0.locationInfo,
                                                         community: $0.community, uid: $0.ownerUid) }
            completion(handles)
            return
        }

        let db = Firestore.firestore()
        var endStr = str
        var lastChar = endStr.removeLast()
        lastChar = Character(UnicodeScalar(UInt8(lastChar.asciiValue ?? 121) + 1) ) // 122 = z; last ascii char
        endStr.append(lastChar)

        var t = db.collection("users").whereField("lowercase", isGreaterThanOrEqualTo: str)
            .whereField("lowercase", isLessThan: endStr)
        
        if let community = community {
            t = t.whereField("community", isEqualTo: community)
        }
        t.limit(to: maxCount)
            .order(by: "lowercase", descending: true)
            .getDocuments { [self] (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                let _handles = snapshot.documents.compactMap { (document) -> _UserHandle? in
                    print(document)
                    var item: _UserHandle?
                    do {
                        item = try document.data(as: _UserHandle.self)
                        item?.ownerUid = document.documentID
                    } catch {
                        print(error)
                    }
                    return item
                }
                _cache = _handles
                searchTerm = str
                let handles = _handles.compactMap { UserHandle(name: $0.name, locationInfo: $0.locationInfo,
                                                               community: $0.community, uid: $0.ownerUid ?? "uid missing") }

                completion(handles)
            }
        }
    }
}
