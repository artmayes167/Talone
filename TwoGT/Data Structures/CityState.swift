// CityState.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let cityState = try CityState(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCityState { response in
//     if let cityState = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - CityState
@objcMembers class CityState: NSObject, Codable {
    var locationInfo: AppLocationInfo
    var community: String?

    init(locationInfo: AppLocationInfo, community: String?) {
        self.locationInfo = locationInfo
        self.community = community
    }
}

// MARK: CityState convenience initializers and mutators

extension CityState {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(CityState.self, from: data)
        self.init(locationInfo: me.locationInfo, community: me.community)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        locationInfo: AppLocationInfo,
        community: String? = ""
    ) -> CityState {
        return CityState(
            locationInfo: locationInfo,
            community: community
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension CityState {
    func displayName() -> String {
        return locationInfo.city.capitalized + ", " + locationInfo.state.capitalized
    }
    
    func isLocationValid() -> Bool {
        // Should not be able to create without a city and state
        return (!locationInfo.city.isEmpty && !locationInfo.state.isEmpty)
    }
}

// LocationInfo.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let locationInfo = try LocationInfo(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseLocationInfo { response in
//     if let locationInfo = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - LocationInfo
@objcMembers class AppLocationInfo: NSObject, Codable {
    var city, state: String
    var country: String = "USA"
    var geoLocation: GeoLocation?

    init(city: String, state: String, country: String = "USA", geoLocation: GeoLocation? = nil) {
        self.city = city
        self.state = state
        self.country = country
        self.geoLocation = geoLocation
    }
}

// MARK: LocationInfo convenience initializers and mutators

extension AppLocationInfo {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(AppLocationInfo.self, from: data)
        self.init(city: me.city, state: me.state, country: me.country, geoLocation: me.geoLocation)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        city: String,
        state: String,
        country: String,
        geoLocation: GeoLocation?? = nil
    ) -> AppLocationInfo {
        return AppLocationInfo(
            city: city,
            state: state,
            country: country,
            geoLocation: geoLocation ?? self.geoLocation
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// GeoLocation.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let geoLocation = try GeoLocation(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseGeoLocation { response in
//     if let geoLocation = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - GeoLocation
@objcMembers class GeoLocation: NSObject, Codable {
    var geographicCoordinates: GeographicCoordinates?

    init(geographicCoordinates: GeographicCoordinates?) {
        self.geographicCoordinates = geographicCoordinates
    }
}

// MARK: GeoLocation convenience initializers and mutators

extension GeoLocation {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(GeoLocation.self, from: data)
        self.init(geographicCoordinates: me.geographicCoordinates)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        geographicCoordinates: GeographicCoordinates?? = nil
    ) -> GeoLocation {
        return GeoLocation(
            geographicCoordinates: geographicCoordinates ?? self.geographicCoordinates
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// GeographicCoordinates.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let geographicCoordinates = try GeographicCoordinates(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseGeographicCoordinates { response in
//     if let geographicCoordinates = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - GeographicCoordinates
@objcMembers class GeographicCoordinates: NSObject, Codable {
    var latitude, longitude: Double?

    init(latitude: Double?, longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: GeographicCoordinates convenience initializers and mutators

extension GeographicCoordinates {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(GeographicCoordinates.self, from: data)
        self.init(latitude: me.latitude, longitude: me.longitude)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        latitude: Double?? = nil,
        longitude: Double?? = nil
    ) -> GeographicCoordinates {
        return GeographicCoordinates(
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
