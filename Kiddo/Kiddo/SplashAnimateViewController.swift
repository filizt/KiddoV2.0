//
//  SplashAnimateViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 2/23/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Crashlytics
import ParseFacebookUtilsV4
import Mixpanel

class SplashAnimateViewController: UIViewController, PFLogInViewControllerDelegate {

    @IBOutlet weak var findFunThingstodoLabel: UILabel!

    @IBOutlet weak var dot1: UIImageView!
    @IBOutlet weak var dot2: UIImageView!
    @IBOutlet weak var dot3: UIImageView!

    var isFirstTime: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showStatusBar(style: .lightContent)

        self.dot1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.dot2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.dot3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.findFunThingstodoLabel.alpha = 0
        self.dot1.alpha = 0
        self.dot2.alpha = 0
        self.dot3.alpha = 0

        if isFirstTime {
            UIView.animate(withDuration: 2,
                           delay: 0.0,
                           options: .curveEaseIn,
                           animations: {
                            self.findFunThingstodoLabel.alpha = 1
            },
                           completion:{ (finished) in
                            self.dot1.alpha = 1
                            self.dot2.alpha = 1
                            self.dot3.alpha = 1
                            UIView.animate(withDuration: 0.3,
                                           delay: 0.0,
                                           options: [],
                                           animations: {
                                            self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                            self.dot2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                            self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            },completion: { (finished) in
                                UIView.animate(withDuration: 0.2, delay: 0.0, options:.curveEaseInOut, animations: {
                                    self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                    self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                    self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                }, completion: { (finished) in
                                    UIView.animate(withDuration: 0.2, delay: 0.0, options:.curveEaseInOut, animations: {
                                        self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                        self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                        self.dot3.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                    }, completion: { (finished) in
                                        UIView.animate(withDuration: 0.2, delay: 0.0, options:.curveEaseInOut, animations: {
                                            self.dot1.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                            self.dot2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                            self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                        }, completion: { (finished) in
                                            UIView.animate(withDuration: 0.2, delay: 0.0, options:.curveEaseInOut, animations: {
                                                self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                self.dot2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                            }, completion: { (finished) in
                                                UIView.animate(withDuration: 0.2, delay: 0.0, options:.curveEaseInOut, animations: {
                                                    self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                    self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                    self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                }, completion: { (finished) in
                                                    UIView.animate(withDuration: 0.2, delay: 0.0, options:[.curveEaseInOut], animations: {
                                                        self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                        self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                        self.dot3.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                    }, completion: { (finished) in
                                                        UIView.animate(withDuration: 0.2, delay: 0.0, options:[.curveEaseInOut], animations: {
                                                            self.dot1.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                            self.dot2.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                            self.dot3.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                        }, completion: { (finished) in
                                                            self.dot1.isHidden = true
                                                            self.dot2.isHidden = true
                                                            self.dot3.isHidden = true
                                                            self.isFirstTime = false
                                                            self.prepareForLaunch()
                                                        })
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
            })
        } else {
            prepareForLaunch()
        }
    }



    func prepareForLaunch() {

        if UserDefaults.standard.bool(forKey: "loginSkipped") {
            self.performSegue(withIdentifier: "showTimeline", sender: nil)
        }

        if let user = PFUser.current() {
            if let userObjId = user.objectId {
                Mixpanel.mainInstance().identify(distinctId: userObjId)
            }
            self.performSegue(withIdentifier: "showTimeline", sender: nil)
        } else {
            if !emailSubmisionNeeded() { // this is here because of backward compatibility reasons. For existing email users, we'll crea PFUser and log them in. The next time they would not reach here, as PFUser.current() will return true.
                //TODO: at some point we need to retire emailSubmissionNeeded check as all the users would have a log in by then.
                self.performSegue(withIdentifier: "showTimeline", sender: nil)
            } else {
                let logInViewController = LogInViewController()
                logInViewController.fields = [PFLogInFields.facebook,PFLogInFields.dismissButton]
                logInViewController.delegate = self
                logInViewController.emailAsUsername = false
                logInViewController.facebookPermissions = ["public_profile", "email"]

                self.present(logInViewController, animated: true, completion: nil )
            }
        }
    }

    func emailSubmisionNeeded() -> Bool {
        if let email = UserDefaults.standard.object(forKey: "email") as? String {
            //if we already have the email, this is a returning email user, let's create a pfUser
            let pfUser = PFUser()
            pfUser.email = email
            pfUser.username = email
            pfUser.password = "a"

            if (try? pfUser.signUp()) != nil {
                let userInfo: PFObject = PFObject(className: "UserInfo")
                userInfo["logInMethod"] = "Email"
                userInfo["firstName"] = pfUser.username
                userInfo["email"] = pfUser.email
                userInfo["parseUser"] = PFUser.current()
                userInfo["parseUserId"] = PFUser.current()?.objectId

                userInfo.saveInBackground()

                let mixpanel = Mixpanel.mainInstance()
                mixpanel.createAlias(pfUser.objectId!,
                                     distinctId: mixpanel.distinctId);
                mixpanel.identify(distinctId: mixpanel.distinctId)
                mixpanel.track(event: "SignUp", properties: ["Source" : "Email", "Date" : Date()] )
                mixpanel.people.set(properties: ["Email": pfUser.email!, "Source": "Email", "Date": Date(), "ParseUserId": pfUser.objectId ?? "" ])

            }
            

            return false
        }

        return true
    }

    func facebookLoginNeeded() -> Bool {
        guard let lastFacebookLoginRequest = UserDefaults.standard.object(forKey: "FacebookLoginSkipped") as? Date else { return true }

        if Int(lastFacebookLoginRequest.timeIntervalSinceNow * -1) >= (60*60*24*3) {
            //it's been 3 days or more since we last asked the user to log in. Let's try that again.
            return true
        }

        return false
    }


    //MARK: PFLogInViewControllerDelegate functions

    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        let mixpanel = Mixpanel.mainInstance()

        if user.isNew {
            mixpanel.createAlias(user.objectId!,
                                 distinctId: mixpanel.distinctId);
            mixpanel.identify(distinctId: mixpanel.distinctId)

            if let accessToken = FBSDKAccessToken.current() {
                PFFacebookUtils.logInInBackground(with: accessToken) { (userLoggedIn, error) in
                    guard error == nil else { print("\(error?.localizedDescription ?? "Error while loggin in on Facebook")"); return }
                    if userLoggedIn != nil {
                        let requestParameters = ["fields": "id, first_name, last_name, name, email, age_range, gender, locale"]
                        if let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters){
                            userDetails.start { (connection, result, error) -> Void in
                                guard error == nil else { print("\(error?.localizedDescription ?? "Error getting graph data")"); return }

                                if let result = result {
                                    let userCreated = User.create(from: result)
                                    let userInfo: PFObject = PFObject(className: "UserInfo")
                                    userInfo["facebookId"] = userCreated.id
                                    userInfo["logInMethod"] = "Facebook"
                                    userInfo["firstName"] = userCreated.first_name
                                    userInfo["lastName"] = userCreated.last_name
                                    userInfo["fullName"] = userCreated.full_name
                                    userInfo["email"] = userCreated.email
                                    userInfo["gender"] = userCreated.gender
                                    userInfo["locale"] = userCreated.locale
                                    userInfo["parseUser"] = PFUser.current()
                                    userInfo["parseUserId"] = PFUser.current()?.objectId ?? ""

                                    userInfo.saveInBackground()

                                    mixpanel.track(event: "SignUp", properties: ["Source" : "Facebook", "Date" : Date()] )
                                    mixpanel.people.set(properties: ["User First Name" : userCreated.first_name, "User Last Name" : userCreated.last_name, "Email" : userCreated.email, "Source" : "Facebook", "Date" : Date(), "ParseUserId": user.objectId! ?? "" ])

                                } else {
                                    print("Uh oh. There was an problem getting the fb graph info.")
                                }
                            }
                        }
                    }
                }
            }
        } else { // We reach here if the user already signed up with his FB before (There is an exisint PFUser in the database) Maybe returning user after an app uninstall
            mixpanel.identify(distinctId: user.objectId!)
            mixpanel.people.set(properties: ["Resurrected User": true])
        }
        presentTimeline()
    }


    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        Answers.logSignUp(withMethod: "Facebook", success: 0, customAttributes: ["FacebookLogin": "Error"])
        presentTimeline()
    }

    //Skipping log in triggers this.
    func logInViewControllerDidCancelLog(in logInController: PFLogInViewController) {
        //Answers.logSignUp(withMethod: "Facebook", success: 0, customAttributes: ["FacebookLogin": "Skipped"])
        //UserDefaults.standard.set(Date(), forKey: "FacebookLoginSkipped")
        //presentTimeline()

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
//        //self.present(controller, animated: true, completion: nil)
//
//        self.dismiss(animated: true, completion: { self.present(controller, animated: true, completion: nil) } )
        UserDefaults.standard.set(true, forKey: "loginSkipped")
        presentTimeline()

    }

    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        presentTimeline()
    }


    func presentTimeline() {
        self.dismiss(animated: true, completion: { self.performSegue(withIdentifier: "showTimeline", sender: nil) } )
    }
}
