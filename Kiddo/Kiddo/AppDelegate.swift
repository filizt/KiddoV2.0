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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?
    var rootVC: UIViewController?
    private let userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

       let configuration = ParseClientConfiguration {
            $0.applicationId = "8383nfjf9393nnd"
            $0.clientKey = "93993djfjfjkskkskggh667"
            $0.server = "https://location-reminder-serverfk.herokuapp.com/parse"
        }

        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)

        if PFUser.current() == nil {
            let logInViewController = LogInViewController()
            logInViewController.fields = [PFLogInFields.facebook, PFLogInFields.dismissButton]
            logInViewController.delegate = self
            logInViewController.emailAsUsername = false
            logInViewController.signUpController?.delegate = self
            logInViewController.facebookPermissions = ["public_profile", "email"]
            

            window?.rootViewController? = logInViewController
            window?.makeKeyAndVisible()

         }


        UNUserNotificationCenter.current().delegate = self

        if let settings = UIApplication.shared.currentUserNotificationSettings {
            if settings.types.contains([.alert, .sound]) {
                //User already authorized for local notifications. Register with Fabric.
            } else {
                //not registered for local notifications
                //let's check if enough time passed since we last asked, and if so ask again.
                if let lastNotificationAuthRequest = userDefaults.object(forKey: "UserNotificationsDeniedKey") as? Date {
                    if Int(lastNotificationAuthRequest.timeIntervalSinceNow * -1) > (60*60*24*7) {
                        //It's been more than 7 days since we last asked, good enough, let's ask again.
                        UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound]) {(granted, error) in
                            if granted {
                                //schedule notifications.
                                self.scheduleLocalNotifications()
                            } else {
                                print("Notification access denied.")
                                let today = Date()
                                self.userDefaults.set(today, forKey: "UserNotificationsDeniedKey")
                            }
                        }
                    }
                }
            }
        }

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle local notification from background or closed")
        //from background this method is called.
    }

    func scheduleLocalNotifications() {

        //let date: Date = Date()
        let calendar = Calendar(identifier: .gregorian)
        var date = DateComponents()
        date.calendar = calendar
        date.timeZone = .current
        //date.month = components.month
        //date.day = components.day
        date.hour = 8
        date.minute = 30


        //let components = calendar.dateComponents(in: .current, from: date)
        //var components = calendar.dateComponents(in: .current, from: date)
        //components.setValue(58, for: .minute)
        //let expirationDate = Calendar.current.date(byAdding: components, to: date)


        let content = UNMutableNotificationContent()
        content.title = "Kiddo"
        content.body = "Check out the new events added to Kiddo!"
        content.sound = UNNotificationSound.default()
        //content.categoryIdentifier = "myCategory"

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)


        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)


        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }


    //MARK: PFLogInViewControllerDelegate functions

    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }

    //To-Do: Need to handle error conditions
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        let alert = UIAlertController(title: "Facebook LogIn Failed", message: "Facebook login failed due to an error. We skipped the login step. You can still enjoy Kiddo!", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)

        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    //Skipping log in triggers this.
    func logInViewControllerDidCancelLog(in logInController: PFLogInViewController) {
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        let alert = UIAlertController(title: "Facebook LogIn Cancelled", message: "Facebook login cancelled. No worries! You can still enjoy Kiddo without signing up!", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)

        window?.rootViewController?.present(alert, animated: true, completion: nil)

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

