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

class SplashAnimateViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{

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

        self.dot1.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.dot2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        showStatusBar(style: .lightContent)
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
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.dot1.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                            self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            self.dot3.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            self.dot1.alpha = 1
                            self.dot2.alpha = 1
                            self.dot3.alpha = 1
                           },
                           completion: { (finished) in
                            UIView.animate(withDuration: 0.3, delay: 0.0, options:.curveEaseInOut, animations: {
                                self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                self.dot2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                }, completion: { (finished) in
                                    UIView.animate(withDuration: 0.3, delay: 0.0, options:.curveEaseInOut, animations: {
                                        self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                        self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                        self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                    }, completion: { (finished) in
                                        UIView.animate(withDuration: 0.3, delay: 0.0, options:.curveEaseInOut, animations: {
                                            self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                            self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                            self.dot3.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                        }, completion: { (finished) in
                                            UIView.animate(withDuration: 0.3, delay: 0.0, options:.curveEaseInOut, animations: {
                                                self.dot1.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                self.dot2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                            }, completion: { (finished) in
                                                UIView.animate(withDuration: 0.3, delay: 0.0, options:.curveEaseInOut, animations: {
                                                    self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                    self.dot2.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                    self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                }, completion: { (finished) in
                                                    UIView.animate(withDuration: 0.3, delay: 0.0, options:[.curveEaseInOut], animations: {
                                                        self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                        self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                                        self.dot3.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                                                    }, completion: { (finished) in
                                                        UIView.animate(withDuration: 0.3, delay: 0.0, options:[.curveEaseInOut], animations: {
//                                                            self.dot1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                                                            self.dot2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//                                                            self.dot3.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
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

        self.performSegue(withIdentifier: "showTimeline", sender: nil)

//        if PFUser.current() != nil {
//            self.performSegue(withIdentifier: "showTimeline", sender: nil)
//        } else {
//            if !emailSubmisionNeeded() {
//                self.performSegue(withIdentifier: "showTimeline", sender: nil)
//            } else {
//                let logInViewController = LogInViewController()
//                logInViewController.fields = [PFLogInFields.facebook,PFLogInFields.dismissButton]
//                logInViewController.delegate = self
//                logInViewController.emailAsUsername = false
//                logInViewController.signUpController?.delegate = self
//                logInViewController.facebookPermissions = ["public_profile", "email"]
//
//                self.present(logInViewController, animated: true, completion: nil )
//            }
//        }
    }

    func emailSubmisionNeeded() -> Bool {
        if let _ = UserDefaults.standard.object(forKey: "email") as? String {
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
        if user.isNew {
            Answers.logSignUp(withMethod: "Facebook", success: 1, customAttributes: ["FacebookLogin": "Success"])
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

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        //self.present(controller, animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: { self.present(controller, animated: true, completion: nil) } )


    }

    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        presentTimeline()
    }


    func presentTimeline() {
        self.dismiss(animated: true, completion: { self.performSegue(withIdentifier: "showTimeline", sender: nil) } )
    }
}
