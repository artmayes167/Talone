// Event.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let event = try Event(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseEvent { response in
//     if let event = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Event
@objcMembers class Event: NSObject, Codable {
    var eventItem: Item?
    var personalNotes: String?
    var needIDS, haveIDS: [String]?
    var when: Int?
    var address: Address?

    enum CodingKeys: String, CodingKey {
        case eventItem, personalNotes
        case needIDS = "needIds"
        case haveIDS = "haveIds"
        case when, address
    }

    init(eventItem: Item?, personalNotes: String?, needIDS: [String]?, haveIDS: [String]?, when: Int?, address: Address?) {
        self.eventItem = eventItem
        self.personalNotes = personalNotes
        self.needIDS = needIDS
        self.haveIDS = haveIDS
        self.when = when
        self.address = address
    }
}

// MARK: Event convenience initializers and mutators

extension Event {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Event.self, from: data)
        self.init(eventItem: me.eventItem, personalNotes: me.personalNotes, needIDS: me.needIDS, haveIDS: me.haveIDS, when: me.when, address: me.address)
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
        eventItem: Item?? = nil,
        personalNotes: String?? = nil,
        needIDS: [String]?? = nil,
        haveIDS: [String]?? = nil,
        when: Int?? = nil,
        address: Address?? = nil
    ) -> Event {
        return Event(
            eventItem: eventItem ?? self.eventItem,
            personalNotes: personalNotes ?? self.personalNotes,
            needIDS: needIDS ?? self.needIDS,
            haveIDS: haveIDS ?? self.haveIDS,
            when: when ?? self.when,
            address: address ?? self.address
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
