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
    
    class func user() -> User  {
        guard let d = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = d.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            if let u = try managedContext.fetch(fetchRequest).first {
                return u
            } else {
                return AppDelegate.createUser(inContext: managedContext)
            }
        } catch _ as NSError {
          return User()
        }
    }
    
    class func createUser(inContext managedContext: NSManagedObjectContext) -> User {
        
        let entity =
          NSEntityDescription.entity(forEntityName: "User",
                                     in: managedContext)!
        
       guard let user = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as? User else {
                                                fatalError()
        }
        
//        restaurant.setValue(name, forKeyPath: "name")
//        restaurant.setValue(cuisine, forKey: "cuisine")
        
        do {
          try managedContext.save()
            return user
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
            fatalError()
        }
    }

    var window: UIWindow?
    var newsFetcher = NewsFeedFetcher()     // TODO: decide better place for data holders/fetchers/writers

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let def = UserDefaults.standard
        if !def.bool(forKey: "vigilant") {
            def.set(false, forKey: "vigilant")
        }
        if def.string(forKey: "admin") == nil {
            def.set("xxxx", forKey: "admin")
        }
        
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
        
        //try? Auth.auth().signOut() // Needed to test login-process
        
        checkIfAuthenticatedAndProgress()
        // Otherwise, go to sign-in view

// Fetch latest news for this city.
//        newsFetcher.fetchNews { newsItems in
//            print(newsItems)
//        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:] ) -> Bool {
        // Notify FB application delegate
           ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

        }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return userActivity.webpageURL.flatMap(handlePasswordlessSignIn)!
    }
    
    private func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        let link = url.absoluteString
        
        if Auth.auth().isSignIn(withEmailLink: link) {  // Checks if the link is a sign-in link; can be used one-time only.
            UserDefaults.standard.set(link, forKey: "Link")
            // Post a notification to the PasswordlessViewController to resume authentication
            NotificationCenter.default
              .post(Notification(name: Notification.Name("PasswordlessEmailNotificationSuccess")))
            return true
        }
        return false
    }
    
    private func checkIfAuthenticatedAndProgress() {

        if Auth.auth().currentUser?.isEmailVerified ?? false, (/*Auth.auth().currentUser?.isAnonymous ??*/ false) == false  {
            print("Email verified!!! User not anonymous!")
        
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let mainStoryboard = UIStoryboard(name: "NoHome", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "Main App VC") as! BaseSwipeVC

            self.window?.rootViewController = mainVC
            self.window?.makeKeyAndVisible()
        }

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        do {
            BackgroundTask.run(application: application) { backgroundTask in
                _ = save()
                backgroundTask.end()
            }
        }
    }
    
    func save() -> Bool {
        do {
            try persistentContainer.viewContext.save()
            return true
        }
        catch {
            return false
        }
    }
    
    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        let scene = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//        scene.storyboard = UIStoryboard.init(name: "NoHome", bundle: nil)
//        return scene
//    }

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

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
        let container = NSPersistentCloudKitContainer(name: "TwoGT")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // TODO: - Make sure this doesn't merge thigs we don't want merged
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

class BackgroundTask {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskIdentifier.invalid

    init(application: UIApplication) {
        self.application = application
    }

    class func run(application: UIApplication, handler: (BackgroundTask) -> ()) {
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
        if (identifier != UIBackgroundTaskIdentifier.invalid) {
            application.endBackgroundTask(identifier)
        }

        identifier = UIBackgroundTaskIdentifier.invalid
    }
}
