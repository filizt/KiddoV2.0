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
import Mixpanel

var testMode = false
var appState = AppStateTracker.State.appInNonTransitionalState
var lastAppActiveTimeStamp : Date?

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

//        if !isSimulator() {
//            Fabric.with([Crashlytics.self])
//        }

        if testMode {
             Mixpanel.initialize(token: "a5c3cfa22228541b11759f218a092df7")
            Mixpanel.initialize(token: <#T##String#>, launchOptions: <#T##[UIApplicationLaunchOptionsKey : Any]?#>, flushInterval: <#T##Double#>, instanceName: <#T##String#>)
        } else {
             Mixpanel.initialize(token: "fda2cfdb1bb3e523b6842ac03ff88fba")
             Fabric.with([Crashlytics.self])
        }

        UNUserNotificationCenter.current().delegate = self

        prefetchImages()
        //fetchSeasonalEventRequirements()
        checkVersionInfoAndRequestDownload()

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

        Mixpanel.mainInstance().track(event: "App Launch", properties: [:])

        if let currentParseUserObjectId = PFUser.current()?.objectId {
            let userInfo: PFObject = PFObject(className: "UserAppLaunchHistory")
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = PFUser.current()?.objectId
            userInfo.saveInBackground()

        }


        return true
    }

    func checkVersionInfoAndRequestDownload() {
        let query = PFQuery(className: "VersionInfoUpdate")
        query.getFirstObjectInBackground(block: { (object, error) in
            guard error == nil else {
                print ("Error retrieving version info from Parse")
                return
            }
            if let object = object {
                if object["IsOn"] as! Bool == true {
                    VersionManager.shared.isEnabled = object["IsOn"] as! Bool
                    VersionManager.shared.currentActiveVersion = object["currentVersion"] as! String
                }
            }
        })
    }

    func prefetchImages() {

        guard let startDate = DateUtil.shared.todayStart() else { return }
        guard let endDate = DateUtil.shared.addOneMonth(to: startDate) else { return }

        let eventsQuery = PFQuery(className: "EventInstance")
        eventsQuery.whereKey("eventDate", lessThanOrEqualTo: endDate)
        eventsQuery.whereKey("eventDate", greaterThan: startDate)
        eventsQuery.includeKey("eventImageId")
        eventsQuery.limit = 3000

        eventsQuery.findObjectsInBackground { (eventInstances, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let objects = eventInstances {
                SimpleCache.fetchImages(objects: objects)
            }
        }
    }

//    func fetchSeasonalEventRequirements() {
//        let query = PFQuery(className: "SeasonalEvents")
//        query.getFirstObjectInBackground(block: { (object, error) in
//            guard error == nil else {
//                print ("Error retrieving image cache limit from Parse")
//                return
//            }
//            if let object = object {
//                if object["isEnabled"] as! Bool == true {
//                    SeasonalEvent.shared.isEnabled = object["isEnabled"] as! Bool
//                    SeasonalEvent.shared.name = object["name"] as! String
//                }
//            }
//        })
//    }



    func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let date = DateUtil.shared.mediumDateString(from: Date())
        Answers.logCustomEvent(withName: "NotificationViewed", customAttributes: ["Date":date])
        
    }


    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (!Branch.getInstance().handleDeepLink(url)) {
            return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[.sourceApplication] as! String,
                                                                     annotation: options[.annotation])
        }

        return true
    }
    //The problem is, it calls second time after dismissing system services alert (location, push notifications, photos)
    //https://stackoverflow.com/questions/39622392/applicationwillresignactive-called-without-reason-on-ios-10-swift-3
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        //if we didn't leave the app due to locallyspawnedprocesses, then let's record the time we're leaving the app
        lastAppActiveTimeStamp = Date()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        //if it's been an hour since the last time we checked the app, let's reset it
        if let lastAppActiveTimeStamp = lastAppActiveTimeStamp {
            if Int(lastAppActiveTimeStamp.timeIntervalSinceNow * -1) > (60*60) {
                appState = AppStateTracker.State.appWillEnterForegroundFromLongInactivity
            }
        }

        switch appState {
        case .appWillEnterForegroundFromLocallySpawnedProcess(let process):
            switch process {
            case .FacebookLogin:
                print("no-op for now")
            case .Maps:
                print("no-op for now")
            case .Settings:
                UIApplication.shared.registerForRemoteNotifications()
            case .Browser:
                print("no-op for now")
            }
            print("no-op for now")
        case .appWillEnterForegroundFromLongInactivity:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navController = storyboard.instantiateViewController(withIdentifier: "navController")
            self.window!.rootViewController = navController
        case .appInNonTransitionalState:
            print("No-op: Not in transition mode")

        }

        appState = AppStateTracker.State.appInNonTransitionalState //Reset!

    }

    //runs first time and anytime after that the app transitions back in
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Push Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let currentInstallation = PFInstallation.current()
//        currentInstallation?.setDeviceTokenFrom(deviceToken)
//        currentInstallation?.saveInBackground()
        if let user = PFUser.current() {
            Mixpanel.mainInstance().people.addPushDeviceToken(deviceToken)
        }

//        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
//
//        if let user = PFUser.current() {
//            Mixpanel.mainInstance().people.append(properties: [ "$ios_devices": [deviceTokenString]] )
//        }
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

