// Need.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let need = try Need(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseNeed { response in
//     if let need = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Need
@objcMembers class Need: NSObject, Codable {
    var fulfilled: Bool?
    var needItem: Item?
    var personalNotes: String?
    var needIDS, haveIDS, eventIDS: [String]?

    enum CodingKeys: String, CodingKey {
        case fulfilled, needItem, personalNotes
        case needIDS = "needIds"
        case haveIDS = "haveIds"
        case eventIDS = "eventIds"
    }

    init(fulfilled: Bool?, needItem: Item?, personalNotes: String?, needIDS: [String]?, haveIDS: [String]?, eventIDS: [String]?) {
        self.fulfilled = fulfilled
        self.needItem = needItem
        self.personalNotes = personalNotes
        self.needIDS = needIDS
        self.haveIDS = haveIDS
        self.eventIDS = eventIDS
    }
}

// MARK: Need convenience initializers and mutators

extension Need {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Need.self, from: data)
        self.init(fulfilled: me.fulfilled, needItem: me.needItem, personalNotes: me.personalNotes, needIDS: me.needIDS, haveIDS: me.haveIDS, eventIDS: me.eventIDS)
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
        fulfilled: Bool?? = nil,
        needItem: Item?? = nil,
        personalNotes: String?? = nil,
        needIDS: [String]?? = nil,
        haveIDS: [String]?? = nil,
        eventIDS: [String]?? = nil
    ) -> Need {
        return Need(
            fulfilled: fulfilled ?? self.fulfilled,
            needItem: needItem ?? self.needItem,
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

extension Need {
        private func areHeavyRequirementsMet() -> Bool {
            guard let h = needItem?.headline, let d = needItem?.needDescription else { return false }
            return !h.trimmingCharacters(in: [" "]).isEmpty && !d.trimmingCharacters(in: [" "]).isEmpty
        }
    
        func areAllRequiredFieldsFilled(light: Bool) -> Bool {
            if light { return true }
            return areHeavyRequirementsMet()
        }
    
    func getHeadlineOrNil() -> String? {
        return needItem?.headline
    }
    
    func getNotesOrNil() -> String? {
        return needItem?.haveDescription
    }
}
