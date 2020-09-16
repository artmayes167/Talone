// Have.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let have = try Have(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseHave { response in
//     if let have = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Have
@objcMembers class Have: NSObject, Codable {
    var haveItem: Item?
    var personalNotes: String?
    var needIDS, haveIDS, eventIDS: [String]?

    enum CodingKeys: String, CodingKey {
        case haveItem, personalNotes
        case needIDS = "needIds"
        case haveIDS = "haveIds"
        case eventIDS = "eventIds"
    }

    init(haveItem: Item?, personalNotes: String?, needIDS: [String]?, haveIDS: [String]?, eventIDS: [String]?) {
        self.haveItem = haveItem
        self.personalNotes = personalNotes
        self.needIDS = needIDS
        self.haveIDS = haveIDS
        self.eventIDS = eventIDS
    }
}

// MARK: Have convenience initializers and mutators

extension Have {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Have.self, from: data)
        self.init(haveItem: me.haveItem, personalNotes: me.personalNotes, needIDS: me.needIDS, haveIDS: me.haveIDS, eventIDS: me.eventIDS)
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
        haveItem: Item?? = nil,
        personalNotes: String?? = nil,
        needIDS: [String]?? = nil,
        haveIDS: [String]?? = nil,
        eventIDS: [String]?? = nil
    ) -> Have {
        return Have(
            haveItem: haveItem ?? self.haveItem,
            personalNotes: personalNotes ?? self.personalNotes,
            needIDS: needIDS ?? self.needIDS,
            haveIDS: haveIDS ?? self.haveIDS,
            eventIDS: eventIDS ?? self.eventIDS
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Have {
        private func areHeavyRequirementsMet() -> Bool {
            guard let h = haveItem?.headline, let d = haveItem?.haveDescription else { return false }
            return !h.trimmingCharacters(in: [" "]).isEmpty && !d.trimmingCharacters(in: [" "]).isEmpty
        }
    
        func areAllRequiredFieldsFilled(light: Bool) -> Bool {
            if light { return true }
            return areHeavyRequirementsMet()
        }
    
    func getHeadlineOrNil() -> String? {
        return haveItem?.headline
    }
    
    func getNotesOrNil() -> String? {
        return haveItem?.haveDescription
    }
}
