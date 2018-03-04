//
//  SignUpViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 5/16/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var goBackButton: UIButton!

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

    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {

        if let email = emailField.text, isValidEmail(emailStr: emailField.text!) {

            let emailObject: PFObject = PFObject(className: "UserEmail")
            emailObject["email"] = email
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                emailObject["deviceUUID"] = vendorIdentifier.uuidString
            } else {
                emailObject["deviceUUID"] = "0"
            }

            let user = PFUser()
            user.email = ""
            user.password = "a"
            user.username = email

            let existingUser = try? PFUser.logIn(withUsername: email, password: "a")

            if let user = existingUser {
                //it's an existing user loggin back in(after a reinstall or unexplainable thing that deleted hise session token); just make sure he's logged in and current returns the user
               self.performSegue(withIdentifier: "pushTimeline", sender: nil)
            } else {
                //it's a new user go through the singUp routine
                user.signUpInBackground(block: { (result, error) in
                    if result == true {
                        UserDefaults.standard.set(email, forKey: "email")
                        emailObject.saveInBackground(block: { (result, error) in
                            if result == false {
                                //If we hit here, there is a problem with signing up not related to the user flow but due to maybe network issue or a backend issue. Let's record it but let the user see the timeline.
                                let userLogInIssue: PFObject = PFObject(className: "UserLogInIssue")
                                userLogInIssue["parseUserEmail"] = user.email
                                if let objID = user.objectId {
                                    userLogInIssue["parseUserObjectId"] = objID
                                }

                                if let error = error {
                                    userLogInIssue["error"] = error.localizedDescription
                                }

                                userLogInIssue.saveInBackground()
                            }
                            self.performSegue(withIdentifier: "pushTimeline", sender: nil)
                        })
                    }
                })
            }
        } else {
            let alertController = UIAlertController(title: "Invalid email address.", message: "Please enter a valid email address.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
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

