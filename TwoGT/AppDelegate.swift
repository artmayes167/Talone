//
//  AppDelegate.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var newsFetcher = NewsFeedFetcher()     // TODO: decide better place for data holders/fetchers/writers
    // var needsWriter = NeedsDbWriter()       // TODO: decide better place for data holders/fetchers/writers
    var needsFetcher = NeedsDbFetcher()     // TODO: decide better place for data holders/fetchers/writers
    var havesFetcher = HavesDbFetcher()     // TODO: decide better place for data holders/fetchers/writers

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Notify FB application delegate
        ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )

        if UserDefaults.standard.string(forKey: "uuid") == nil {
            let uuid = UUID().uuidString
            UserDefaults.standard.setValue(uuid, forKeyPath: "uuid")
        }

        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        // Fetch latest news for this city.
        newsFetcher.fetchNews { newsItems in
            print(newsItems)
        }

        // Fetch latest needs (DEMO)
        needsFetcher.fetchNeeds("Chicago", "IL", "USA") { needs in
            print(needs)
        }

        // Fetch haves matching needs
        havesFetcher.fetchHaves(matching: ["Food", "Shelter"], "Chicago", "IL", "USA", completion: { (haves) in
            print(haves)
        })

        // SignIn Anonymously
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("User: isAnonymous: \(isAnonymous); uid: \(uid)")
            
            // DEMO ONLY
            // Create a mock need - this works; use cautiously.
/*
            let locData = NeedsDbWriter.LocationInfo(city: "Chicago", state: "IL", country: "USA", address: nil, geoLocation: nil)
            let need = NeedsDbWriter.NeedItem(category: "Food", description: "any food, preferably low cholestorol", validUntil: 4124045393, owner: "peter.parker@gmail.com", locationInfo: locData)
    
            self.needsWriter.addNeed(need, completion: { error in
                if error == nil {
                    print("Need added!")
                } else {
                    print("Error writing a need: \(error!)")
                }
            })*/
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:] ) -> Bool {

            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

        }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        let scene = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//        scene.storyboard = UIStoryboard.init(name: "NoHome", bundle: nil)
//        return scene
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, authenticationError in
                DispatchQueue.main.async {
                    completion(success, authenticationError)
                }
            }
        } else {

        }
    }

//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else {
//            return
//        }
//
//        ApplicationDelegate.shared.application(
//            UIApplication.shared,
//            open: url,
//            sourceApplication: nil,
//            annotation: [UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentCloudKitContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentCloudKitContainer(name: "TwoGT")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate.
                  // You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support

//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

}
