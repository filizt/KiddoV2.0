//
//  AppDelegate.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4
import UserNotifications
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?
    var rootVC: UIViewController?
    private let userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

       let configuration = ParseClientConfiguration {
            $0.applicationId = "1G2h3j45Rtf3s"
            $0.clientKey = "1kjHsfg72348nkKnwl2"
            $0.server = "https://kiddoapp.herokuapp.com/parse"
        }

        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)

        if !isSimulator() {
             Fabric.with([Crashlytics.self])
        }

        UNUserNotificationCenter.current().delegate = self

        fetchImageCacheLimitAndImages()
        requestAuthForNotifications()

        return true
    }

    func fetchImageCacheLimitAndImages() {
        let query = PFQuery(className: "ImageCache")
        query.getFirstObjectInBackground(block: { (object, error) in
            guard error == nil else {
                print ("Error retrieving image cache limit from Parse")
                return
            }

            if let object = object {
                SimpleCache.shared.capacity = object["limit"] as! Int
                self.fetchImages()
            }
        })
    }
    
    func fetchImages() {
        let query = PFQuery(className: "EventImage")
        query.limit = SimpleCache.shared.capacity
        query.findObjectsInBackground(block: { (objects, error) in
            guard error == nil else {
                print ("Error retrieving image data from Parse")
                return
            }

            if let objects = objects {
                for object in objects {
                    guard let imageFile = object["image"] as? PFFile else { return }

                    imageFile.getDataInBackground({ (data, error) in
                        guard error == nil else {
                            print ("Error retrieving image data from Parse")
                            return
                        }
                        guard let imageData = data else { return }
                        guard let image = UIImage(data: imageData) else { return }

                        SimpleCache.shared.setImage(image, key: object.objectId!)

                    })
                }
            }
        })
    }

    //MARK: Local Notifications

    func requestAuthForNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus != .authorized {
                UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound]) {(granted, error) in
                    if granted {
                        //schedule notifications.
                        self.scheduleLocalNotifications()
                        Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Authroized"])
                    } else {
                        Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Denied"])
                    }
                }
            }
        })
    }

    //Turns out we can only ask the user once for notification auth. So commenting below code out.
    //    func notificationsAuthNeeded() -> Bool {
    //        if let lastNotificationAuthRequest = UserDefaults.standard.object(forKey: "UserNotificationsDeniedKey") as? Date {
    //            guard ((lastNotificationAuthRequest.timeIntervalSinceNow * -1) >= (60*60*24*3)) else { return false }
    //        }
    //
    //        return true //first time user case
    //    }

    func scheduleLocalNotifications() {
        //time interval is every 3 days
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*24*2), repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Kiddo"
        content.body = "New events and activities added every day! Come check them out!"
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let date = DateUtil.shared.today()
        Answers.logCustomEvent(withName: "NotificationViewed", customAttributes: ["Date":date])
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }   

}

