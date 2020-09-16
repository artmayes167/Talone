// User.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let user = try User(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseUser { response in
//     if let user = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - User
@objcMembers class User: NSObject, Codable {
    var user: UserClass?

    init(user: UserClass?) {
        self.user = user
    }
}

// MARK: User convenience initializers and mutators

extension User {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(User.self, from: data)
        self.init(user: me.user)
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
        user: UserClass?? = nil
    ) -> User {
        return User(
            user: user ?? self.user
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// UserClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let userClass = try UserClass(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseUserClass { response in
//     if let userClass = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - UserClass
@objcMembers class UserClass: NSObject, Codable {
    var handle: String
    var personalData: PersonalData?
    var avatarData: AvatarData?
    var cards: [Card]?
    var searches: [String: [String]]?

    init(handle: String, personalData: PersonalData?, avatarData: AvatarData?, cards: [Card]?, searches: [String: [String]]? = nil) {
        self.handle = handle
        self.personalData = personalData
        self.avatarData = avatarData
        self.cards = cards
        self.searches = searches
    }
}

// MARK: UserClass convenience initializers and mutators

extension UserClass {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(UserClass.self, from: data)
        self.init(handle: me.handle, personalData: me.personalData, avatarData: me.avatarData, cards: me.cards)
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
        handle: String?,
        personalData: PersonalData?? = nil,
        avatarData: AvatarData?? = nil,
        cards: [Card]?? = nil,
        searches: [String: [String]]?? = nil
    ) -> UserClass {
        return UserClass(
            handle: handle ?? self.handle,
            personalData: personalData ?? self.personalData,
            avatarData: avatarData ?? self.avatarData,
            cards: cards ?? self.cards,
            searches: searches ?? self.searches
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// AvatarData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let avatarData = try AvatarData(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseAvatarData { response in
//     if let avatarData = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - AvatarData
@objcMembers class AvatarData: NSObject, Codable {
    var imageString: String?

    init(imageString: String?) {
        self.imageString = imageString
    }
}

// MARK: AvatarData convenience initializers and mutators

extension AvatarData {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(AvatarData.self, from: data)
        self.init(imageString: me.imageString)
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
        imageString: String?? = nil
    ) -> AvatarData {
        return AvatarData(
            imageString: imageString ?? self.imageString
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// PersonalData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let personalData = try PersonalData(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePersonalData { response in
//     if let personalData = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - PersonalData
@objcMembers class PersonalData: NSObject, Codable {
    var addresses: [Address]?
    var phone: [Phone]?
    var email: String
    var socialMedia: [SocialMedia]?
    var imageString: String?
    var phoneNumbers: [Phone]?

    init(addresses: [Address]? = [], phone: [Phone]? = [], email: String, socialMedia: [SocialMedia]? = [], imageString: String? = nil, phoneNumbers: [Phone]? = []) {
        self.addresses = addresses
        self.phone = phone
        self.email = email
        self.socialMedia = socialMedia
        self.imageString = imageString
        self.phoneNumbers = phoneNumbers
    }
}

// MARK: PersonalData convenience initializers and mutators

extension PersonalData {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(PersonalData.self, from: data)
        self.init(addresses: me.addresses, phone: me.phone, email: me.email, socialMedia: me.socialMedia, imageString: me.imageString, phoneNumbers: me.phoneNumbers)
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
        addresses: [Address]?? = nil,
        phone: [Phone]?? = nil,
        email: String?,
        socialMedia: [SocialMedia]?? = nil,
        imageString: String?? = nil,
        phoneNumbers: [Phone]?? = nil
    ) -> PersonalData {
        return PersonalData(
            addresses: addresses ?? self.addresses,
            phone: phone ?? self.phone,
            email: email ?? self.email,
            socialMedia: socialMedia ?? self.socialMedia,
            imageString: imageString ?? self.imageString,
            phoneNumbers: phoneNumbers ?? self.phoneNumbers
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Address.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let address = try Address(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseAddress { response in
//     if let address = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Address
@objcMembers class Address: NSObject, Codable {
    var title: String?
    var street: Street?
    var cityState: CityState?

    init(title: String?, street: Street?, cityState: CityState?) {
        self.title = title
        self.street = street
        self.cityState = cityState
    }
}

// MARK: Address convenience initializers and mutators

extension Address {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Address.self, from: data)
        self.init(title: me.title, street: me.street, cityState: me.cityState)
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
        title: String?? = nil,
        street: Street?? = nil,
        cityState: CityState?? = nil
    ) -> Address {
        return Address(
            title: title ?? self.title,
            street: street ?? self.street,
            cityState: cityState ?? self.cityState
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Street.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let street = try Street(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseStreet { response in
//     if let street = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Street
@objcMembers class Street: NSObject, Codable {
    var lineOne, lineTwo: String?

    init(lineOne: String?, lineTwo: String?) {
        self.lineOne = lineOne
        self.lineTwo = lineTwo
    }
}

// MARK: Street convenience initializers and mutators

extension Street {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Street.self, from: data)
        self.init(lineOne: me.lineOne, lineTwo: me.lineTwo)
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
        lineOne: String?? = nil,
        lineTwo: String?? = nil
    ) -> Street {
        return Street(
            lineOne: lineOne ?? self.lineOne,
            lineTwo: lineTwo ?? self.lineTwo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Phone.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let phone = try Phone(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePhone { response in
//     if let phone = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Phone
@objcMembers class Phone: NSObject, Codable {
    var title, number: String?

    init(title: String?, number: String?) {
        self.title = title
        self.number = number
    }
}

// MARK: Phone convenience initializers and mutators

extension Phone {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Phone.self, from: data)
        self.init(title: me.title, number: me.number)
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
        title: String?? = nil,
        number: String?? = nil
    ) -> Phone {
        return Phone(
            title: title ?? self.title,
            number: number ?? self.number
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// SocialMedia.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let socialMedia = try SocialMedia(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseSocialMedia { response in
//     if let socialMedia = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - SocialMedia
@objcMembers class SocialMedia: NSObject, Codable {
    var platform, userName: String?

    init(platform: String?, userName: String?) {
        self.platform = platform
        self.userName = userName
    }
}

// MARK: SocialMedia convenience initializers and mutators

extension SocialMedia {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(SocialMedia.self, from: data)
        self.init(platform: me.platform, userName: me.userName)
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
        platform: String?? = nil,
        userName: String?? = nil
    ) -> SocialMedia {
        return SocialMedia(
            platform: platform ?? self.platform,
            userName: userName ?? self.userName
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
