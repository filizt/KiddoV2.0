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
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.eventAddress.text = event.eventAddress
        // self.eventStartTime.text = event.eventStartTime

        //self.eventImage.image = //self.image
       // self.eventImage.contentMode = .scaleAspectFill

        //navigationController?.navigationBar.topItem?.title = event.eventTitle

//        if event.eventDescription != nil {
//            self.eventDescription.text = event.eventDescription?.html2AttributedString?.string
//        }
//        if event.eventUrl != nil {
//            moreInfoButton.isHidden = false
//        }

    }

    @IBAction func moreInformationButton(_ sender: AnyObject) {
        self.presentSafariViewController(url: event.originalEventURL!)

    }

    func presentSafariViewController(url: String) {
        let safariVC = SFSafariViewController(url:URL(string: url)!)
        self.present(safariVC, animated: true, completion: nil)
    }


}
