//
//  StateAndCDHelpers.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import CoreData
import LocalAuthentication
import FBSDKCoreKit
import Firebase

typealias CoreDataGod = AppDelegateHelper
class AppDelegateHelper: NSObject {
    static let user = AppDelegateHelper.getUser()
    
    class var managedContext: NSManagedObjectContext {
        guard let d = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return d.persistentContainer.viewContext
    }
    
    class func getUser() -> User {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            if let u = try managedContext.fetch(fetchRequest).first {
                print("Successfully fetched User")
                return u
            } else {
                print("Creating new User")
                return AppDelegateHelper.createUser()
            }
        } catch _ as NSError {
            return AppDelegateHelper.createUser()
        }
    }

    class func createUser() -> User {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: CoreDataGod.managedContext)!
        let user = User(entity: entity, insertInto: CoreDataGod.managedContext)
        user.handle = UserDefaults.standard.string(forKey: DefaultsKeys.userHandle.rawValue)!
        if let _ = UserDefaults.standard.string(forKey: DefaultsKeys.taloneEmail.rawValue), let uid = UserDefaults.standard.string(forKey: DefaultsKeys.uid.rawValue) {
            user.uid = uid
            return user
        } else {
            fatalError()
        }
    }
}

typealias  State = IntroPageSaveNames
enum IntroPageSaveNames: String, CaseIterable {
    case stateDefaultsKey
    case enterEmail, verify, enterHandle, importVC = "import", youIntro
    
    func segueValue() -> String {
        let firstLetter = String(self.rawValue.first!)
        let range = rawValue.index(after: rawValue.startIndex)..<rawValue.endIndex
        let withoutFirst = rawValue[range]
        let s = "to" + firstLetter.capitalized + withoutFirst
        return s
    }
}

class StateManager: NSObject {
    func configureIntro() -> State? {
        if let string = UserDefaults.standard.string(forKey: State.stateDefaultsKey.rawValue) {
            return State(rawValue: string)
        }
        return nil
    }
}

class BackgroundTask {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskIdentifier.invalid

    init(application: UIApplication) {
        self.application = application
    }

    class func run(application: UIApplication, handler: (BackgroundTask) -> Void) {
        // NOTE: The handler must call end() when it is done

        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }

    func begin() {
        self.identifier = application.beginBackgroundTask {
            self.end()
        }
    }

    func end() {
        if identifier != UIBackgroundTaskIdentifier.invalid {
            application.endBackgroundTask(identifier)
        }

        identifier = UIBackgroundTaskIdentifier.invalid
    }
}
