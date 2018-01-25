//
//  FeedbackAlertViewController.swift
//  Kiddo
//
//  Created by Mike Miksch on 1/24/18.
//  Copyright © 2018 Filiz Kurban. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackAlertViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var noThanksButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyFormatting()

    }
    
    @IBAction func rateNowPressed(_ sender: Any) {
        print("recieving touches")
        let appID = "1210910332"
        if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)") {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: { (complete) in
                if complete {
                    self.defaults.set(true, forKey: "Left Feedback")
                }
            })
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sendFeedbackPressed(_ sender: Any) {
                print("recieving touches")
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["feedback@thekiddoapp.com"])
        mail.setSubject("Kiddo App Feedback")
        present(mail, animated: true, completion: {
            self.defaults.set(true, forKey: "Left Feedback")
        })
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func noThanksPressed(_ sender: Any) {
                print("recieving touches")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let today = dateFormatter.string(from: Date())
        defaults.set(today, forKey: "Start Date")
        dismiss(animated: true, completion: nil)
    }
    
    func applyFormatting() {
        rateButton.layer.cornerRadius = 10
        feedbackButton.layer.cornerRadius = 10
        noThanksButton.layer.cornerRadius = 10
        
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOpacity = 0.5
        alertView.layer.shadowOffset = CGSize.zero
        alertView.layer.shadowRadius = 5
        alertView.layer.shadowPath = UIBezierPath(rect: alertView.bounds).cgPath
        
        if !MFMailComposeViewController.canSendMail() {
            feedbackButton.isEnabled = false
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    

}
