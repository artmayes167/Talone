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

final class Saves: NSObject {
    
    static let shared = Saves()
        
    static let saveLocation = "SavedLocations"
    var user: User?
    
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
            let archiver = try NSKeyedArchiver.archivedData(withRootObject: Saves.shared.user as Any, requiringSecureCoding: true)
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
    
    func encode(with: NSCoder) {
        
    }
    
    private class func loadSaves() {
        
        guard let data = Saves.getData() else {
            print(ArchiveError.noDataFound())
            return
        }
        
        do {
            Saves.shared.user = try User(data: data)
            
            print("++++++++++Created User From Data!!!!!!!+++++++++++++")
            print(ArchiveError.none())
            return
        } catch {
            print(ArchiveError.dataFoundButNotUnarchived())
            return
        }
        
    }
    
    private class func getData() -> Data? {
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
    
//    func encode(with coder: NSCoder) {
//
//    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
////        var cityStateContainer = container
////            .nestedContainer(keyedBy: CityState.CodingKeys.self, forKey: .home)
////        try cityStateContainer.encode(home?.city, forKey: .city)
////        try cityStateContainer.encode(home?.state, forKey: .state)
////        try cityStateContainer.encode(home?.country, forKey: .country)
//
//        try container.encode(home, forKey: .home)
//        try container.encode(alternates, forKey: CodingKeys.alternates)
//    }
    
    static var supportsSecureCoding: Bool = true
}

