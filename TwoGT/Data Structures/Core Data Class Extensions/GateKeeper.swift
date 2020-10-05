//
//  GateKeeper.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import CoreData

typealias GateKeeper = CodableCardTemplateInstanceManager

class CodableCardTemplateInstanceManager {
    /**
    This is the only method FiB should need to call to encode card data.
     - Returns: JSON-formatted string
     */
    func buildCodableInstanceAndEncode(instance: CardTemplateInstance) -> Data {
        let codableInstance = CodableCardTemplateInstance(instance: instance)
        let encoder = newJSONEncoder()
        
        do {
            let data = try encoder.encode(codableInstance)
            return data
        } catch {
            fatalError()
        }
    }
    
    /**
        This is the only method FiB should need to call to decode card data.
        - Parameter data: JSON-formatted string
     */
    func decodeCodableInstance(data: Data) -> CardTemplateInstance {
        let decoder = newJSONDecoder()
        do {
            let codableInstance = try decoder.decode(CodableCardTemplateInstance.self, from: data)
            return CardTemplateInstance.create(codableCard: codableInstance)
        } catch {
            fatalError()
        }
    }
}
