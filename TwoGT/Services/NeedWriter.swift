//
//  NeedWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

//import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseGeneric {

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
        var description: String?
        var validUntil: Int
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        var locationInfo: LocationInfo
    }
    
}

class NeedsDbWriter: NeedsBase {
    func addNeed(_ need: NeedItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("needs").document().setData(from: need)
        } catch {
            // handle the error here
            print(error)
            completion(error)
        }
        completion(nil)
    }
}
