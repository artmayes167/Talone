// Purpose.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let purpose = try Purpose(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePurpose { response in
//     if let purpose = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Purpose
@objcMembers class Purpose: NSObject, Codable {
    var purpose: PurposeClass?

    init(purpose: PurposeClass?) {
        self.purpose = purpose
    }
}

// MARK: Purpose convenience initializers and mutators

extension Purpose {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Purpose.self, from: data)
        self.init(purpose: me.purpose)
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
        purpose: PurposeClass?? = nil
    ) -> Purpose {
        return Purpose(
            purpose: purpose ?? self.purpose
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// PurposeClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let purposeClass = try PurposeClass(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePurposeClass { response in
//     if let purposeClass = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - PurposeClass
@objcMembers class PurposeClass: NSObject, Codable {
    var category: String
    var cityState: CityState
    var needs: [Need]?
    var haves: [Have]?
    var events: [Event]?

    init(category: String, cityState: CityState, needs: [Need]?, haves: [Have]?, events: [Event]?) {
        self.category = category
        self.cityState = cityState
        self.needs = needs
        self.haves = haves
        self.events = events
    }
}

// MARK: PurposeClass convenience initializers and mutators

extension PurposeClass {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(PurposeClass.self, from: data)
        self.init(category: me.category, cityState: me.cityState, needs: me.needs, haves: me.haves, events: me.events)
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
        category: String,
        cityState: CityState,
        needs: [Need]?? = nil,
        haves: [Have]?? = nil,
        events: [Event]?? = nil
    ) -> PurposeClass {
        return PurposeClass(
            category: category,
            cityState: cityState,
            needs: needs ?? self.needs,
            haves: haves ?? self.haves,
            events: events ?? self.events
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
