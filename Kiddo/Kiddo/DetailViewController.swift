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

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAgeInfo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    var event: Event!
    var image: UIImage!
    var cachedImageViewSize: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.eventAddress.text = event.eventAddress
        // self.eventStartTime.text = event.eventStartTime

        self.eventImage.image = self.image
        //self.eventDescription.text = event.description
        self.eventAgeInfo.text = "AGES 0-5"

        navigationController?.navigationBar.topItem?.title = event.title

        self.cachedImageViewSize = self.eventImage.frame;
        scrollView.delegate = self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y;

        if (y > 0) {
            self.eventImage.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.cachedImageViewSize.size.width+y, height: self.cachedImageViewSize.size.height+y)
            self.eventImage.center = CGPoint(x:self.view.center.x, y:self.eventImage.center.y);
        }
    }

    @IBAction func moreInformationButton(_ sender: AnyObject) {
        self.presentSafariViewController(url: event.originalEventURL!)

    }

    func presentSafariViewController(url: String) {
        let safariVC = SFSafariViewController(url:URL(string: url)!)
        self.present(safariVC, animated: true, completion: nil)
    }


}
