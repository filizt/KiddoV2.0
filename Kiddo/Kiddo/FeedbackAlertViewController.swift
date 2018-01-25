//
//  FeedbackAlertViewController.swift
//  Kiddo
//
//  Created by Mike Miksch on 1/24/18.
//  Copyright © 2018 Filiz Kurban. All rights reserved.
//

import UIKit

class FeedbackAlertViewController: UIViewController {

    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var noThanksButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateNowPressed(_ sender: Any) {
    }
    @IBAction func sendFeedbackPressed(_ sender: Any) {
    }
    @IBAction func noThanksPressed(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
