//
//  FiltersViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 9/21/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()

    }

    override func viewWillAppear(_ animated: Bool) {
        showStatusBar(style: .lightContent)
    }

     var onShowEventsPressed : ((_ data: (String, String)) -> ())?

    @IBAction func showEventsButtonPressed(_ sender: UIButton) {
        sendFilterCriteria(data: "ABC")
    }

    func sendFilterCriteria(data: String) {
        // Whenever you want to send data back to viewController1, check
        // if the closure is implemented and then call it if it is
        //self.onShowEventsPressed!("today", "Indoor")
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("cancel pressed")

        self.dismiss(animated: true, completion: nil)

    }

    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {

    }

    //MARK: Setup Navigation Bar
    private func setUpNavigationBar() {
        let newColor = UIColor(red:0.25, green:0.18, blue:0.35, alpha:1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = newColor
        navigationController?.navigationBar.backgroundColor = newColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]


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
