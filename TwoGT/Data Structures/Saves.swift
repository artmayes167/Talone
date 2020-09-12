//
//  Saves.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/12/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

class Saves {
    static let shared = Saves()
    
    var home: CityState?
    var alternates: [CityState]?
    
    func saveSaves() {
        let encodedData = Data.init(from: Saves.shared)
        _ = KeyChain.save(key: "saveLocations", data: encodedData)
    }
    
    func loadSaves() {
        let data = KeyChain.load(key: "saveLocations")
        let unencodedData = data?.to(type: Saves.self)
        Saves.shared.home = unencodedData?.home
        Saves.shared.alternates = unencodedData?.alternates
    }
}
