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
import Branch
import UIViewController_ODStatusBar
import ForecastIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?
    var rootVC: UIViewController?
    let forecastIO = DarkSkyClient(apiKey: "e6054a4d0d1b152edd4ba15a16ee9d9d")

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

        prefetchImages()
        fetchSeasonalEventRequirements()
        requestAuthForNotifications()

        if launchOptions != nil {
            if let remoteNotificationDict = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary{
                handleNotification(notificationDict: remoteNotificationDict)
            }
        }

        Branch.getInstance()?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (params, error) in
            if error == nil && params?["+clicked_branch_link"] != nil && params?["eventId"] != nil {
                let eventId = params?["eventId"] as! String
                 Event.pushedEventId = eventId

                if let date = params?["forDateTime"] {
                    Event.pushedEventForDateTime = date as? String
                }

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navController = storyboard.instantiateViewController(withIdentifier: "navController")
                self.window!.rootViewController = navController
            }
        })
        return true
    }



    func prefetchImages() {
        let events = PFQuery(className: "EventObject")
        var dates = [Date]()
        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
        dates.append(date)
        if let tomorrow = DateUtil.shared.tomorrow() {
            dates.append(tomorrow)
        }
        if let later = DateUtil.shared.later() {
            dates.append(later)
        }
        if let laterPlusOne = DateUtil.shared.laterPlusOne() {
            dates.append(laterPlusOne)
        }
        events.whereKey("allEventDates", containedIn: dates)
        events.whereKey("isActive", equalTo: true)

        let popularEvents = PFQuery(className:"EventObject")
        popularEvents.whereKey("allEventDates", greaterThanOrEqualTo: date)
        popularEvents.whereKey("isActive", equalTo: true)
        popularEvents.whereKey("isPopular", equalTo: true)

        let query = PFQuery.orQuery(withSubqueries: [events, popularEvents])
        query.findObjectsInBackground { (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let objects = dateObjects {
                SimpleCache.fetchImages(objects: objects)
            }
        }
    }

    func fetchSeasonalEventRequirements() {
        let query = PFQuery(className: "SeasonalEvents")
        query.getFirstObjectInBackground(block: { (object, error) in
            guard error == nil else {
                print ("Error retrieving image cache limit from Parse")
                return
            }
            if let object = object {
                if object["isEnabled"] as! Bool == true {
                    SeasonalEvent.shared.isEnabled = object["isEnabled"] as! Bool
                    SeasonalEvent.shared.name = object["name"] as! String
                }
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
                UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound,.badge]) {(granted, error) in
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


    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)

        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {

        if (!Branch.getInstance().handleDeepLink(url)) {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
        }

        return true
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

    // MARK: Push Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)

        let currentInstallation = PFInstallation.current()
        currentInstallation?.setDeviceTokenFrom(deviceToken)
        currentInstallation?.saveInBackground()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfoDict = notification.request.content.userInfo as NSDictionary

        if let aps = userInfoDict["aps"] as? NSDictionary {
            if let message = aps["alert"] as? String {
                let notificationAlert = UIAlertController(title: "Notification", message: message, preferredStyle: UIAlertControllerStyle.alert)
                notificationAlert.addAction(UIAlertAction(title: "Show", style: .default, handler: { (action) in
                    self.handleNotification(notificationDict: userInfoDict)
                }))
                notificationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                window?.rootViewController?.present(notificationAlert, animated: true, completion: nil)
            }
        }
    }

    func handleNotification(notificationDict: NSDictionary){
        if let notificationType = notificationDict["t"] as? Int {
            if notificationType == 1 {
                if let eventId = notificationDict["id"] as? String {
                    Event.pushedEventId = eventId
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let navController = storyboard.instantiateViewController(withIdentifier: "navController")
                    self.window!.rootViewController = navController
                }
            }
        }
    }
}

