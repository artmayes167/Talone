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
public final class AppDelegateHelper: NSObject {
    static let user = AppDelegateHelper.getUser()
    private static var container: NSPersistentCloudKitContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    static var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    class func save() {
        let d = UIApplication.shared.delegate as! AppDelegate
        if !d.saveContext() {
            print("--------------Failed again.")
        }
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
        let user = User(context: CoreDataGod.managedContext)
            return user
    }
}

typealias  State = IntroPageSaveNames
enum IntroPageSaveNames: String, CaseIterable {
    case stateDefaultsKey
    case enterEmail, verify, enterHandle, addHome, importVC = "import", youIntro
    
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

//extension NSManagedObjectID: FetchSource {
//
// override func valueForUndefinedKey() {
//
//    //Attempt to unwrap the underlying object from the moc
//    let mocObject: NSManagedObject = CoreDataGod.managedContext.object(id: self)
//
//        return [object valueForKey:key];
//    }
//}
