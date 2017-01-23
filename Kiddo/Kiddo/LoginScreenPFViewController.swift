//
//  LoginScreenPFViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 12/17/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class LoginScreenPFViewController: PFLogInViewController {

    override func viewDidLoad() {

        var imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 480,
                                                  height: 800))
        imageView.image = UIImage(named: "bg_portrait.jpg");

        self.logInView?.addSubview(imageView)
        self.logInView?.addSubview((self.logInView?.facebookButton)!)
        self.logInView?.logo = nil

        self.logInView?.facebookButton?.addTarget(self, action: #selector(logInFacebook), for: UIControlEvents.touchUpInside)
    }

    func logInFacebook() {
        let permissions = ["email"]
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("****User logged in through Facebook!")
                }
            } else {
                //Hit this case also when user is already logged in.
                print("****Uh oh. The user cancelled the Facebook login.")
            }
        }
    }

}
