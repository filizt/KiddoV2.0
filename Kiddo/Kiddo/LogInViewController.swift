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

class LogInViewController: PFLogInViewController {

    var backgroundImage: UIImageView!
    private var facebookButtonAnimationShown: Bool = false

    override func viewDidLoad() {
         super.viewDidLoad()
        //set background image
        backgroundImage = UIImageView(image: UIImage(named: "bg_portraitNew.png"))
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.logInView!.insertSubview(backgroundImage, at: 0)

        logInView?.logo = nil
        self.logInView?.dismissButton?.setTitle("Skip", for: .normal)
        self.logInView?.dismissButton?.setTitleColor(UIColor.lightGray, for: .normal)
        self.logInView?.dismissButton?.setTitleShadowColor(UIColor.black, for: .normal)
        self.logInView?.dismissButton?.setImage(nil, for: .normal)

    }

    //gets called right after viewDidLoad
    //LayoutSubviews, however, is called once per run loop on any view that has had setNeedsLayout or  setNeedsDisplayInRect called on it - this includes whenever a subview has been added to the view, scrolling, resizing, etc.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRect(x: 0,y:  0,width:  self.logInView!.frame.width, height: self.logInView!.frame.height)

        let dismissButtonFrame = logInView?.dismissButton?.frame
        logInView?.dismissButton?.frame = CGRect(x:(self.logInView?.frame.width)! - 56, y: 28,  width:50, height: (dismissButtonFrame?.height)!)

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
