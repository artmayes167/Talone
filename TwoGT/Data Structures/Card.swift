// Card.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let card = try Card(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCard { response in
//     if let card = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Card
@objcMembers class Card: NSObject, Codable {
    var handle: String?
    var personalData: PersonalData?
    var avatarData: AvatarData?
    var personalNotes, cardComments: String?

    init(handle: String?, personalData: PersonalData?, avatarData: AvatarData?, personalNotes: String?, cardComments: String?) {
        self.handle = handle
        self.personalData = personalData
        self.avatarData = avatarData
        self.personalNotes = personalNotes
        self.cardComments = cardComments
    }
}

// MARK: Card convenience initializers and mutators

extension Card {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Card.self, from: data)
        self.init(handle: me.handle, personalData: me.personalData, avatarData: me.avatarData, personalNotes: me.personalNotes, cardComments: me.cardComments)
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
        handle: String?? = nil,
        personalData: PersonalData?? = nil,
        avatarData: AvatarData?? = nil,
        personalNotes: String?? = nil,
        cardComments: String?? = nil
    ) -> Card {
        return Card(
            handle: handle ?? self.handle,
            personalData: personalData ?? self.personalData,
            avatarData: avatarData ?? self.avatarData,
            personalNotes: personalNotes ?? self.personalNotes,
            cardComments: cardComments ?? self.cardComments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
