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
import SafariServices

class LogInViewController: PFLogInViewController, UITextViewDelegate {

    var backgroundImage: UIImageView!
    private var facebookButtonAnimationShown: Bool = false
    var privacyText: UITextView!
    var signUpButton: UIButton!
    var welcomeText: UILabel!
    var welcomeSubtext: UILabel!

    override func viewDidLoad() {
         super.viewDidLoad()

        //set background image
        backgroundImage = UIImageView(image: UIImage(named: "bg_portraitBlur2.png"))
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.logInView!.insertSubview(backgroundImage, at: 0)

        //privacy text
        privacyText = UITextView()
        self.privacyText.delegate = self
        let text = "By signing up, you agree to the Kiddo Local Privacy Policy."
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let string = NSMutableAttributedString(string: text)
        let linkRange = string.mutableString.range(of: "Privacy Policy")
        let textRange = string.mutableString.range(of: "By signing up, you agree to the Kiddo Local ")
        string.addAttribute(NSLinkAttributeName, value: "https://www.kiddolocal.com/privacy-policy", range: linkRange)
        string.addAttributes([NSFontAttributeName : UIFont(name: "Avenir-Book", size: 12)!
            , NSForegroundColorAttributeName : UIColor.white, NSParagraphStyleAttributeName:style], range: textRange)

        privacyText.attributedText = string
        privacyText.isEditable = false
        privacyText.backgroundColor = UIColor.clear
        self.view.addSubview(privacyText)

        logInView?.logo = nil

        self.logInView?.dismissButton?.isEnabled = true

        self.signUpButton = UIButton()
        self.signUpButton.setImage(nil, for: .normal)
        self.signUpButton.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        self.signUpButton.setTitle("    Sign up with Email", for: .normal)
        self.signUpButton.setTitleColor(UIColor.white, for: .normal)
        self.signUpButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17)
        self.signUpButton.layer.cornerRadius = 5
        self.signUpButton.addTarget(self, action: #selector(self.handleSignUpButtonTap(sender:)), for: .touchUpInside)
        self.view.addSubview(signUpButton)

//        self.welcomeText = UILabel()
//        self.welcomeText.text = "Welcome to Kiddo Local"
//        self.welcomeText.textColor = UIColor.white
//        self.welcomeText.font = UIFont(name: "Avenir-Black", size: 30)
//        self.welcomeText.textAlignment = .center
//
//        self.welcomeSubtext = UILabel()
//        self.welcomeSubtext.text = "Discover kid-friendly local events and drop-in activities using one intuitive app. Login with Facebook or sign up learn about the best weekend events and upcoming shows."
//        self.welcomeSubtext.textColor = UIColor.white
//        self.welcomeSubtext.font = UIFont(name: "Avenir-Book", size: 15)
//        self.welcomeSubtext.textAlignment = .center
//        self.welcomeSubtext.numberOfLines = 0
//        self.welcomeSubtext.lineBreakMode = .byWordWrapping
//
//        self.view.addSubview(welcomeText)
//        self.view.addSubview(welcomeSubtext)

    }

    func handleSignUpButtonTap(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        self.present(controller, animated: true, completion: nil)

        //self.dismiss(animated: true, completion: { self.present(controller, animated: true, completion: nil) } )
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {

        let userInfo: PFObject = PFObject(className: "UserPrivacyPolicyViewed")
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = PFUser.current()?.objectId
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
        } else if let email = UserDefaults.standard.object(forKey: "email") as? String { //where user didn't log in with FB but used their email to sign up
            userInfo["email"] = email
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
        } else {
            userInfo["parseUser"] = "Unknown"
        }

        userInfo["privacyPolicyViewed"] = true
        userInfo.saveInBackground()

        let safariVC = SFSafariViewController(url:URL)
        self.present(safariVC, animated: true, completion: nil)
        return false
    }


    //gets called right after viewDidLoad
    //LayoutSubviews, however, is called once per run loop on any view that has had setNeedsLayout or  setNeedsDisplayInRect called on it - this includes whenever a subview has been added to the view, scrolling, resizing, etc.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRect(x: 0,y:  0,width:  self.logInView!.frame.width, height: self.logInView!.frame.height)

//        welcomeText.frame = CGRect(x:0, y:0, width:350, height: 40)
//        welcomeText.center = CGPoint(x:185, y:350)
//        welcomeSubtext.frame = CGRect(x:0, y:0, width:300, height: 100)
//        welcomeSubtext.center = CGPoint(x:185, y:420)


        logInView?.dismissButton?.frame = CGRect(x:(logInView?.dismissButton?.frame.origin.x)!, y:(logInView?.dismissButton?.frame.origin.y)!, width:10, height:10)

        logInView?.facebookButton?.frame = CGRect(x:(self.logInView?.facebookButton?.frame.origin.x)!, y: (self.logInView?.facebookButton?.frame.origin.y)! - 85,  width:(self.logInView?.facebookButton?.frame.width)!, height: (self.logInView?.facebookButton?.frame.height)!)

        signUpButton.frame = CGRect(x:(self.logInView?.facebookButton?.frame.origin.x)!, y: (self.logInView?.facebookButton?.frame.origin.y)! + 55,  width:(self.logInView?.facebookButton?.frame.width)!, height: (self.logInView?.facebookButton?.frame.height)!)

        //privacy text frame
        privacyText.frame = CGRect(x: (self.signUpButton.frame.origin.x), y:(self.signUpButton.frame.origin.y) + 48 ,width: (self.signUpButton.frame.size.width), height: (self.signUpButton.frame.size.height))

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard facebookButtonAnimationShown == true else { return }

        if let frame = logInView?.facebookButton?.frame {
            logInView?.facebookButton?.frame = CGRect(x: (self.logInView?.frame.size.width)!, y: frame.origin.y, width: frame.size.width, height: frame.size.height)

            UIView.animate(withDuration: 0.5,
                           delay: 0.20,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.8,
                           options: .curveEaseInOut,
                           animations: {
                               self.logInView?.facebookButton?.frame = frame
                           },
                           completion: { (finished) in
                            self.facebookButtonAnimationShown = true
                           }
            )
        }

    }
}
