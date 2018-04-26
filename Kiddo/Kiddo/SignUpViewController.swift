//
//  SignUpViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 5/16/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import Mixpanel

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var goBackButton: UIButton!
    let mixpanel = Mixpanel.mainInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.submitButton.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        self.submitButton.layer.cornerRadius = 5
        self.emailField.layer.cornerRadius = 5
        self.goBackButton.layer.cornerRadius = 5
        self.submitButton.clipsToBounds = true
        self.emailField.clipsToBounds = true
        self.goBackButton.clipsToBounds = true

        self.emailField.delegate = self
        //self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal

        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.emailField.layer.frame.size.height))
        emailField.leftView = indentView
        emailField.leftViewMode = .always

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {

        if let email = emailField.text, isValidEmail(emailStr: emailField.text!) {
            if let resurrectedUser = try? PFUser.logIn(withUsername: email, password: "a") {
                mixpanel.identify(distinctId: resurrectedUser.objectId!)
                mixpanel.people.set(properties: ["Resurrected User": true])
            } else {
                let pfUser = PFUser()
                pfUser.email = email
                pfUser.username = email
                pfUser.password = "a"

                //it's a new user so go through the singUp routine
                if (try? pfUser.signUp()) != nil {
                    let userInfo: PFObject = PFObject(className: "UserInfo")
                    userInfo["logInMethod"] = "Email"
                    userInfo["firstName"] = pfUser.email
                    userInfo["email"] = pfUser.email
                    userInfo["parseUser"] = PFUser.current()
                    userInfo["parseUserId"] = PFUser.current()?.objectId ?? ""

                    userInfo.saveInBackground()

                    mixpanel.createAlias(pfUser.objectId!,
                                         distinctId: mixpanel.distinctId);
                    mixpanel.identify(distinctId: mixpanel.distinctId)
                    mixpanel.track(event: "SignUp", properties: ["Source" : "Email", "Date" : Date()] )
                    mixpanel.people.set(properties: ["Email" : pfUser.email!, "Source" : "Email", "Date" : Date(), "ParseUserId": pfUser.objectId ?? "" ])

                } else {
                    let userInfo: PFObject = PFObject(className: "UserSignUpError")
                    userInfo["logInMethod"] = "Email"
                    userInfo["firstName"] = pfUser.email
                    userInfo["email"] = pfUser.email
                    userInfo["parseUser"] = PFUser.current()
                    userInfo["parseUserId"] = PFUser.current()?.objectId

                    userInfo.saveInBackground()
                }
                
            }
        } else {
            let alertController = UIAlertController(title: "Invalid email address.", message: "Please enter a valid email address.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
         appState = AppStateTracker.State.appInNonTransitionalState //Invalidate the previously set(FB login) state. We started this as FB but made a non transitional state if user logsin with email.
         self.performSegue(withIdentifier: "pushTimeline", sender: nil)
    }

    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailStr)
    }


    @IBAction func goBackButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil )
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

