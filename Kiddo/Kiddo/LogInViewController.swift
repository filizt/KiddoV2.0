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

    override func viewDidLoad() {
         super.viewDidLoad()
        //set background image
        backgroundImage = UIImageView(image: UIImage(named: "bg_portrait.jpg"))
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.logInView!.insertSubview(backgroundImage, at: 0)
        //below code didn't work for me as the bg image was becoming the top layer covering everything else 
        // in the screen. Turns out we need to insert the subview at the 0 index to avoid that.
        // self.logInView?.addSubview(imageView)


//        let logoImage = UIImage(named: "kiddo")
//        let logo = UIImageView(image: logoImage)

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

        // position logo at top with larger frame
//        logInView!.logo!.sizeToFit()
//        let logoFrame = logInView!.logo!.frame
//        logInView!.logo!.frame = CGRect(x:logoFrame.origin.x, y:logoFrame.origin.y - 250, width: logoFrame.width+50,  height: logoFrame.height+50)


        let dismissButtonFrame = logInView?.dismissButton?.frame
        logInView?.dismissButton?.frame = CGRect(x:(self.logInView?.frame.width)! - 56, y: 28,  width:50, height: (dismissButtonFrame?.height)!)

    }
}
