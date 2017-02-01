//
//  DetailViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import SafariServices
import Parse

class DetailViewController: UIViewController {
    
    var event: Event!
    var image: UIImage!
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAgeInfo: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.eventAddress.text = event.eventAddress
        // self.eventStartTime.text = event.eventStartTime

        self.eventImage.image = self.image
        //self.eventDescription.text = event.description
        self.eventAgeInfo.text = "AGES 0-5"

        navigationController?.navigationBar.topItem?.title = event.title

        calculateViewHeight()

    }

    private func calculateViewHeight() {
        let c1 = eventImage.frame.size.height
        let c2 = eventDescription.frame.size.height
        let c3 = eventAgeInfo.frame.size.height

        var viewFrame = scrollViewContainerView.frame
        viewFrame.size.height = c1 + c2 + c3
    }

    @IBAction func moreInformationButton(_ sender: AnyObject) {
        self.presentSafariViewController(url: event.originalEventURL!)

    }

    func presentSafariViewController(url: String) {
        let safariVC = SFSafariViewController(url:URL(string: url)!)
        self.present(safariVC, animated: true, completion: nil)
    }


}
