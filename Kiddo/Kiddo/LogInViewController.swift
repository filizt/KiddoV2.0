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
import LoginWithAmazon

class LogInViewController: PFLogInViewController {

    var backgroundImage: UIImageView!
    private var facebookButtonAnimationShown: Bool = false
    var amazonButton = UIButton()
    var isUserSignedIn: Bool?
    var token: String?
    
    var productID = "amzn1.application.2d76095fe2414621b67bf02b7085163f"
    var productDsn: String?
    var kClientID = "amzn1.application-oa2-client.0f87c43ca1b048b7931c07f2d2404407"
    var kSecretClientID = "f859d12ce08556f73e0eac401472eaaee368514e14e92c148d21a8ca4a54aaa7"
    var APIKey = "eyJhbGciOiJSU0EtU0hBMjU2IiwidmVyIjoiMSJ9.eyJ2ZXIiOiIzIiwiZW5kcG9pbnRzIjp7ImF1dGh6IjoiaHR0cHM6Ly93d3cuYW1hem9uLmNvbS9hcC9vYSIsInRva2VuRXhjaGFuZ2UiOiJodHRwczovL2FwaS5hbWF6b24uY29tL2F1dGgvbzIvdG9rZW4ifSwiY2xpZW50SWQiOiJhbXpuMS5hcHBsaWNhdGlvbi1vYTItY2xpZW50LjM5ZWE1YjE1ZDdkNDQzMDZiNTI3NWM0OWFmMmI0MWMwIiwiYXBwRmFtaWx5SWQiOiJhbXpuMS5hcHBsaWNhdGlvbi4yZDc2MDk1ZmUyNDE0NjIxYjY3YmYwMmI3MDg1MTYzZiIsImJ1bmRsZVNlZWRJZCI6ImZpbGl6ay5LaWRkbyIsImJ1bmRsZUlkIjoiZmlsaXprLktpZGRvIiwiaXNzIjoiQW1hem9uIiwidHlwZSI6IkFQSUtleSIsImFwcFZhcmlhbnRJZCI6ImFtem4xLmFwcGxpY2F0aW9uLWNsaWVudC4yYTYwNTlmOTNjZjc0NjUyYTQ2OGNiOGQ2ZWI1OTU4MSIsInRydXN0UG9vbCI6bnVsbCwiYXBwSWQiOiJhbXpuMS5hcHBsaWNhdGlvbi1jbGllbnQuMmE2MDU5ZjkzY2Y3NDY1MmE0NjhjYjhkNmViNTk1ODEiLCJpZCI6IjMyM2I5ODFlLTdhMmUtMTFlNy1iNTRiLWM3NzQ0MmFjODkzMyIsImlhdCI6IjE1MDE5NzI0NDg3OTYifQ==.oT1+p7OmOjBUN6wO0o6N4WyC0Ljn/7F+wNXHYDSbFTIlO0hPmIwCOQwPbjJYge/ITieHq+yOiKVz3gePUhy/4nmWOcKzMnROvQanlmzFUqldq1rAucjLJ428ivT+jtkfINKnTKZkFh8P5QZaAj8ytdKmI4Y0a90OPZbmiy4SpwR1I3Tq3/NIvUANV+WNjdXffJoezFwSM5NDil5GOwEw9w9kbs4KetOcY6+mOxfrXjieiHc8fxcv1MFyOyQLkXdSHQTlDG8WlM009RAIYYzGB4g1UHbE0E1xgsuEU1wGXcAfKl+a8uDAMcR4ZrsYVJpjOc3n6cTtQtb3BG1Oq8xyTw=="
  
    
    override func viewDidLoad() {
         super.viewDidLoad()
        //set background image
        backgroundImage = UIImageView(image: UIImage(named: "bg_portraitBlur2.png"))
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.logInView!.insertSubview(backgroundImage, at: 0)

        logInView?.logo = nil

        self.logInView?.dismissButton?.isEnabled = true
        self.logInView?.dismissButton?.setImage(nil, for: .normal)
        self.logInView?.dismissButton?.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        self.logInView?.dismissButton?.setTitle("Subscribe", for: .normal)
        self.logInView?.dismissButton?.setTitleColor(UIColor.white, for: .normal)
        self.logInView?.dismissButton?.layer.cornerRadius = 5
        
        createAmazonLogin()
        checkUserLogin()
    }

    //gets called right after viewDidLoad
    //LayoutSubviews, however, is called once per run loop on any view that has had setNeedsLayout or  setNeedsDisplayInRect called on it - this includes whenever a subview has been added to the view, scrolling, resizing, etc.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRect(x: 0,y:  0,width:  self.logInView!.frame.width, height: self.logInView!.frame.height)

        //let dismissButtonFrame = logInView?.dismissButton?.frame
        logInView?.dismissButton?.frame = CGRect(x:(self.logInView?.facebookButton?.frame.origin.x)!, y: (self.logInView?.facebookButton?.frame.origin.y)! - 65,  width:(self.logInView?.facebookButton?.frame.width)!, height: (self.logInView?.facebookButton?.frame.height)!)

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
    
    func createAmazonLogin() {
        amazonButton.setTitle("", for: .normal)
        amazonButton.frame = CGRect(x: 10, y: 550, width: 400, height: 45)
        amazonButton.layer.cornerRadius = 20
        view.addSubview(amazonButton)
        amazonButton.addTarget(self, action: #selector(pressLoginButton(button:)), for: .touchUpInside)
        amazonButton.setImage(#imageLiteral(resourceName: "amazonButton"), for: .normal)
        amazonButton.setImage(#imageLiteral(resourceName: "amazonButtonPressed"), for: .selected)
    }
    
    func pressLoginButton(button: UIButton) {
        
        let scopeData: [AnyHashable: Any] = ["productID": productID, "productInstanceAttributes": ["deviceSerialNumber": productDsn]]
        let alexaAllScope: AMZNScope = AMZNScopeFactory.scope(withName: "alexa:all", data: scopeData)
        
        let request = AMZNAuthorizeRequest()
        request.scopes = [alexaAllScope]
        request.grantType = AMZNAuthorizationGrantType.token
        
        let authManager = AMZNAuthorizationManager.shared()
        authManager.authorize(request) { (result, userDidCancel, error) in
              // processes the result of the auth call
            if ((error) != nil) {
                print("auth failed due to error")
              
            } else if (userDidCancel) {
                print("auth was cancelled, try again")
            } else {
                // fetch the access token and return to controller
                self.token = result?.token
                self.checkUserLogin()
            }
        }
        
    }
    
    func checkUserLogin() {
        
        let scopeData: [AnyHashable: Any] = ["productID": productID, "productInstanceAttributes": ["deviceSerialNumber": productDsn]]
        let alexaAllScope: AMZNScope = AMZNScopeFactory.scope(withName: "alexa:all", data: scopeData)
        
        let request = AMZNAuthorizeRequest()
        request.scopes = [alexaAllScope]
        request.interactiveStrategy = AMZNInteractiveStrategy.never
        
        let auth = AMZNAuthorizationManager.shared()
        auth.authorize(request) { (result, userDidCancel, error) in
            if error != nil {
                // Error from the SDK, indicating the user was not previously authorized to your app for the requested scopes.
            }
            else {
                // Fetch the access token and return to controller
                self.token = result?.token
                print(result?.token)
                self.checkUserLogin()
            }
        }
    }
    
  

    
}
