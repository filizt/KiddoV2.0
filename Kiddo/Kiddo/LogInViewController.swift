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

        // remove the parse Logo
        let logo = UILabel()
        logo.text = "KIDDO"
        logo.textColor = UIColor.white
        logo.shadowColor = UIColor.lightGray
        logo.shadowOffset = CGSize(width: 2, height: 2)
        logInView?.logo = logo

        //logInView?.dismissButton =


    }

    //gets called right after viewDidLoad
    //LayoutSubviews, however, is called once per run loop on any view that has had setNeedsLayout or  setNeedsDisplayInRect called on it - this includes whenever a subview has been added to the view, scrolling, resizing, etc.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRect(x: 0,y:  0,width:  self.logInView!.frame.width, height: self.logInView!.frame.height)

        // position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRect(x:logoFrame.origin.x, y:self.logInView!.frame.origin.y + 16, width: logInView!.frame.width,  height: logoFrame.height)
    }

   
   

}
