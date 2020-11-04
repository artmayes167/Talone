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
import FirebaseMessaging
import CoreLocation
import UserNotifications

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

extension AppDelegate: CLLocationManagerDelegate {
  
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(for: region)
    }
  }
  
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(for: region)
    }
  }
    
    func handleEvent(for region: CLRegion!) {
      // Show an alert if application is active
      if UIApplication.shared.applicationState == .active {
        guard let message = note(from: region.identifier) else { return }
        window?.rootViewController?.showOkayAlert(title: "", message: message, handler: nil)
      } else {
        // Otherwise present a local notification
        guard let body = note(from: region.identifier) else { return }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "location_change",
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print("Error: \(error)")
          }
        }
      }
    }
    
    func note(from identifier: String) -> String? {
      let geotifications = Geotification.allGeotifications()
      guard let matched = geotifications.filter({
        $0.identifier == identifier
      }).first else { return nil }
      return matched.note
    }
}

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    static var cardObserver = CardReceiverObserver()
    static var linkedNeedsObserver = LinkedWatchersObserver()
    static let stateManager = StateManager()
    
    let locationManager = CLLocationManager()

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let def = UserDefaults.standard
//        if !def.bool(forKey: "vigilant") {
//            def.set(false, forKey: "vigilant")
//        }
        if def.string(forKey: "admin") == nil {
            def.set("xxxx", forKey: "admin")
        }

        // Notify FB application delegate
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        SetupRegistrationForRemoteNotifications(application)

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
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, _) in
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

    public func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
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
        container.loadPersistentStores(completionHandler: { (_, error) in

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
            } catch {
                return false
            }
        }
        return true
    }

    private func SetupRegistrationForRemoteNotifications(_ application: UIApplication) {

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        if UserDefaults.standard.string(forKey: "CloudMessagingToken") != fcmToken {
            _ = UserHandlesDbHandler.registerUserCloudMessagingToken(fcmToken)
            UserDefaults.standard.set(fcmToken, forKey: "CloudMessagingToken")
        }
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo["gcm.message_id"] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo["gcm.message_id"] {
      print("Message ID: \(messageID)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
