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
import FirebaseDynamicLinks


extension AppDelegate {
    fileprivate func handlePasswordlessSignIn(withURL url: URL) -> Bool {
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
    
    /// May move to a flow coordinator
    func setToFlow(storyboardName: String, identifier viewControllerIdentifier: String) {
        DispatchQueue.main.async {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let mainStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as! BaseSwipeVC
            mainVC.view.alpha = 0
            self.window?.rootViewController = mainVC
            self.window?.makeKeyAndVisible()
            UIView.animate(withDuration: 0.5) {
                mainVC.view.alpha = 1
            }
        }
    }
}
    
@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?
    static var cardObserver = CardReceiverObserver()
    static var linkedNeedsObserver = LinkedWatchersObserver()
    static let stateManager = StateManager()

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let def = UserDefaults.standard
        if !def.bool(forKey: "vigilant") {
            def.set(false, forKey: "vigilant")
        }
        if def.string(forKey: "admin") == nil {
            def.set("xxxx", forKey: "admin")
        }

        // Notify FB application delegate
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        return true
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:] ) -> Bool {
        // Notify FB application delegate
           ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let u = dynamiclink?.url {
                _ = self.handlePasswordlessSignIn(withURL: u)
            }
          }
        return handled
    }
    
    /// These may or may not be a good idea
    public func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
       return true
    }

    public func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
       return true
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        if Auth.auth().currentUser?.displayName != nil {
            AppDelegate.cardObserver.startObserving()
            AppDelegate.linkedNeedsObserver.startObservingHaveChanges()
        }
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.cardObserver.stopObserving()
        AppDelegate.linkedNeedsObserver.stopObservingHaveChanges()
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        do {
            BackgroundTask.run(application: application) { backgroundTask in
                _ = try? persistentContainer.viewContext.save()
                backgroundTask.end()
            }
        }
    }

    // MARK: - Core Data stack
    public lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Talone")
        container.loadPersistentStores(completionHandler: { (description, error) in
            
            if let error = error as NSError? {
                guard let rootVC = self.window?.rootViewController else {
                    /// log error
                    return
                }
                let message = String(format: "here's the error: %@.  let us know what happened, because there doesn't seem to be a good way to handle this yet.", error.userInfo)
                rootVC.showOkayAlert(title: "okay", message: message, handler: { _ in
                    rootVC.launchOwnerEmail(subject: "core data error", body: message)
                })
                return
            }
//            description.shouldInferMappingModelAutomatically = true
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    public func saveContext() -> Bool {
        if persistentContainer.viewContext.hasChanges {
            persistentContainer.viewContext.insert(CoreDataGod.user)
            do {
                try persistentContainer.viewContext.save()
                return true
            }
            catch {
                return false
            }
        }
        return true
    }
}
