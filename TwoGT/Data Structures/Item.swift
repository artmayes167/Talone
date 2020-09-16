// Item.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let item = try Item(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseItem { response in
//     if let item = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Item
@objcMembers class Item: NSObject, Codable {
    var id, headline, eventDescription: String?
    var category: String?
    var createdBy: String?
    var createdAt: Int?
    var haveDescription, needDescription: String?

    init(id: String?, headline: String?, eventDescription: String?, category: String?, createdBy: String?, createdAt: Int?, haveDescription: String?, needDescription: String?) {
        self.id = id
        self.headline = headline
        self.eventDescription = eventDescription
        self.category = category
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.haveDescription = haveDescription
        self.needDescription = needDescription
    }
}

// MARK: Item convenience initializers and mutators

extension Item {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Item.self, from: data)
        self.init(id: me.id, headline: me.headline, eventDescription: me.eventDescription, category: me.category, createdBy: me.createdBy, createdAt: me.createdAt, haveDescription: me.haveDescription, needDescription: me.needDescription)
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
        id: String?? = nil,
        headline: String?? = nil,
        eventDescription: String?? = nil,
        category: String?? = nil,
        createdBy: String?? = nil,
        createdAt: Int?? = nil,
        haveDescription: String?? = nil,
        needDescription: String?? = nil
    ) -> Item {
        return Item(
            id: id ?? self.id,
            headline: headline ?? self.headline,
            eventDescription: eventDescription ?? self.eventDescription,
            category: category ?? self.category,
            createdBy: createdBy ?? self.createdBy,
            createdAt: createdAt ?? self.createdAt,
            haveDescription: haveDescription ?? self.haveDescription,
            needDescription: needDescription ?? self.needDescription
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
