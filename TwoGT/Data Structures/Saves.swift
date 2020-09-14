//
//  Saves.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

enum ArchiveError: Error, Equatable {
    case noDataFound(_ description: String = "--------- Saves path is corrupted")
    case dataFoundButNotUnarchived(_ description: String = "--------- Saves data is probably corrupted")
    case failedToWrite(_ description: String = "--------- Saves failed to write to disk")
    case failedToArchive(_ description: String = "--------- Archiver failed to archive Saves.shared for write to disk")
    case failedToGenerateFilePath(_ description: String = "--------- Archiver failed to generate the Bundle path for Saves")
    case failedToGenerateURL(_ description: String = "--------- Archiver failed to generate the URL for Saves")
    case none(_ description: String = "++++++++++ Saves.shared successfully created!")
    
    func printDescription() {
        switch self {
        case .noDataFound(let desc):
            print(desc)
        case .dataFoundButNotUnarchived(let desc):
            print(desc)
        case .failedToWrite(let desc):
            print(desc)
        case .failedToArchive(let desc):
            print(desc)
        case .failedToGenerateFilePath(let desc), .failedToGenerateURL(let desc):
            print(desc)
        case .none(let desc):
            print(desc)
        }
    }
}

class Saves: DatabaseReadyClass, NSSecureCoding, Keyed {
    
    private static var privateSelf = Saves.loadSaves()
    private var liveSaves: Saves?
    
    class func shared() -> Saves {
        return Saves.privateSelf.liveSaves!
    }
        
    static let saveLocation = "SavedLocations"
    
    var home: CityState? 
    var alternates: [CityState]?
    
    enum CodingKeys: String, DatabaseReady {
        case home, alternates
    }
    
    override func propertyValue(_ key: String) -> AnyObject? {
        switch key {
        case CodingKeys.home.rawValue:
            return self.home as CityState?
        case CodingKeys.alternates.rawValue:
            return self.alternates as AnyObject?
        default:
            return nil
        }
    }
    
    @objc static func keys() -> [String] {
        let cases =  NSString.init(string: "\(CodingKeys.allCases)")
        let casesWithout = cases.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let array = casesWithout.components(separatedBy: ", ") as [String]
        var returnArray: [String] = []
        for s in array {
            let newArray = s.components(separatedBy: ".")
            let count = newArray.count
            if count < 2 { fatalError() }
            let str = /*newArray[count-2] + "." +*/ newArray[count-1]
            returnArray.append(str)
        }
        return returnArray
    }
    
    init(home: CityState?, alternates: [CityState]?) {
        self.home = home
        self.alternates = alternates ?? []
    }
    
    class func checkDocumentsDirectory() -> URL? {
        var localUrl: URL
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            localUrl = documentDirectory.appendingPathComponent(Saves.saveLocation)
            if !FileManager.default.fileExists(atPath: localUrl.path) {
                FileManager.default.createFile(atPath: localUrl.path, contents: nil, attributes: nil)
            }
             return localUrl
        }
        return nil
    }
    
    class func saveSaves() -> ArchiveError {
        guard let url = Saves.checkDocumentsDirectory() else { return .failedToGenerateFilePath() }
        do {
            let archiver = try NSKeyedArchiver.archivedData(withRootObject: Saves.shared() as Any, requiringSecureCoding: true)
            do {
                try archiver.write(to: url)
            } catch {
                print(url)
                return .failedToWrite()
            }
        } catch {
            return .failedToArchive()
        }
        return .none()
    }
    
    class func loadSaves() -> Saves {
        var save: Saves = Saves(home: nil, alternates: [])
        
        guard let data = Saves.getData() else {
            print(ArchiveError.noDataFound())
            return save
        }
        
        do {
            let saves = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            if let s = saves as? Saves {
                print("++++++++++NSKeyedUnarchiver found saves!-----  \(s)+++++++++++++")
                save = s
            }
        } catch {
            print(ArchiveError.dataFoundButNotUnarchived())
            return save
        }
        save.liveSaves = save
        print(ArchiveError.none())
        return save
        
    }
    
    class func getData() -> Data? {
        guard let localUrl = Saves.checkDocumentsDirectory() else {
            print(ArchiveError.failedToGenerateURL())
            return nil
        }
        if let cert = NSData(contentsOfFile: localUrl.path) {
            return cert as Data
        } else {
            print(ArchiveError.noDataFound())
            return nil
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(home, forKey: CodingKeys.home.databaseValue())
        coder.encode(alternates, forKey: CodingKeys.alternates.databaseValue())
    }
    
    static var supportsSecureCoding: Bool = true
    
    required init?(coder: NSCoder) {
//        guard
//            let home = coder.decodeObject(of: CityState.self, forKey: CodingKeys.home.databaseValue()) as? CityState,
//            let alternates = coder.decodeObject(of: [CityState].self, forKey: CodingKeys.state.databaseValue()) as? [CityState]
//        else {
//            return nil
//        }
//
//        self.home = home
//        self.alternates = alternates
    }
}
