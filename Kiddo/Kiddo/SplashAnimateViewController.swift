//
//  SplashAnimateViewController.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 2/23/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class SplashAnimateViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{
    
    @IBOutlet weak var kiddoLogo: UIView!
    @IBOutlet weak var kiddoHeart: UIView!

    var loginSuccessful = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.kiddoLogo.alpha = 0
        }) { (finished) in
               self.kiddoLogo.isHidden = true
            UIView.animate(withDuration: 2.0, delay: 0.05, options: .curveEaseInOut, animations: {
                 self.kiddoHeart.transform = CGAffineTransform(translationX: 0, y: -(self.view.frame.size.height/2))

            }, completion: { (finished) in
                self.kiddoHeart.isHidden = true
                 self.prepareForLaunch()

            })
        }
    }
    
    func prepareForLaunch() {

        if PFUser.current() == nil && facebookLoginNeeded() {
            let logInViewController = LogInViewController()
            logInViewController.fields = [PFLogInFields.facebook, PFLogInFields.dismissButton]
            logInViewController.delegate = self
            logInViewController.emailAsUsername = false
            logInViewController.signUpController?.delegate = self
            logInViewController.facebookPermissions = ["public_profile", "email"]

            self.present(logInViewController, animated: false, completion: nil )
        } else {

            self.performSegue(withIdentifier: "showTimeline", sender: nil)
        }
    }

    func facebookLoginNeeded() -> Bool {
        guard let lastFacebookLoginRequest = UserDefaults.standard.object(forKey: "FacebookLoginSkipped") as? Date else { return true }

        if Int(lastFacebookLoginRequest.timeIntervalSinceNow * -1) >= (60*60*24*3) {
            //it's been more than 3 days since we asked the user to log in. Let's try that again.
            return true
        }

        return false
    }


    //MARK: PFLogInViewControllerDelegate functions

    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        //Answers.logLogin(withMethod: "Facebook", success: 1, customAttributes: ["FacebookLogin": "Success"])
        self.loginSuccessful = true
        presentTimeline()
    }

    //To-Do: Need to handle error conditions
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        //Answers.logLogin(withMethod: "Facebook", success: 0, customAttributes: ["FacebookLogin": "Error"])
        self.loginSuccessful = false
        presentTimeline()
    }

    //Skipping log in triggers this.
    func logInViewControllerDidCancelLog(in logInController: PFLogInViewController) {

        //Answers.logLogin(withMethod: "Facebook", success: 0, customAttributes: ["FacebookLogin": "Skip"])

        UserDefaults.standard.set(Date(), forKey: "FacebookLoginSkipped")
        self.loginSuccessful = false
        presentTimeline()

    }

    func presentTimeline() {
        self.dismiss(animated: true, completion: { self.performSegue(withIdentifier: "showTimeline", sender: nil) } )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTimeline" {
            let navController = segue.destination as! UINavigationController
            if let timeLineVC = navController.viewControllers[0] as? TimelineViewController {
                timeLineVC.loginSuccessful = self.loginSuccessful
            }
        }
    }
}
