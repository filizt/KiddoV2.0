//
//  SplashAnimateViewController.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 2/23/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

class SplashAnimateViewController: UIViewController {
    
    @IBOutlet weak var kiddoLogo: UIView!
    @IBOutlet weak var kiddoHeart: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIView.animate(withDuration: 1.5) { 
            self.kiddoLogo.alpha = 0
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
