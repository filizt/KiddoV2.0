//
//  TimeLineViewController.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class TimelineViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var switchControl: UISegmentedControl!

    var events = [Event]() {
        didSet {
            self.timelineTableView.reloadData()
        }
    }

    private var request:PFQuery<PFObject>?
    var eventsTomorrow = [Event]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timelineTableView.dataSource = self
        self.timelineTableView.delegate = self

        let nib = UINib(nibName: "eventCell", bundle: Bundle.main)
        self.timelineTableView.register(nib, forCellReuseIdentifier: EventTableViewCell.identifier())
        
        self.timelineTableView.estimatedRowHeight = 100
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension

        self.setUpNavigationBar()


      //The FB log in is commented out below.
        if PFUser.current() == nil {
            let logInViewController = LogInViewController()
            logInViewController.fields = [PFLogInFields.facebook, PFLogInFields.dismissButton]
            logInViewController.delegate = self
            logInViewController.emailAsUsername = false

            logInViewController.facebookPermissions = ["public_profile", "email"]
            logInViewController.signUpController?.delegate = self
            present(logInViewController, animated: false, completion: nil)

       }
    }

    override func viewWillAppear(_ animated: Bool) {
         self.getEvents()
    }

    private var lastRequest: PFQuery<PFObject>?

    private func getEvents() {
  //      let date = DateUtil.shared.createDate(from: "02-02-2017 09:30")
  //      let query = PFQuery(className: "EventDate")
       // query.where
  //      query.findObjectsInBackground { (objects, error) in

   //         let date2 = objects?[0]
    //        if let objects = objects {
     //           print("blah")
      //      }


        //var eventDate = PFObject(className: "EventDate")
        let eventDateQuery = PFQuery(className: "EventDate")
        let date = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        eventDateQuery.whereKey("eventDate", equalTo: date)
        eventDateQuery.findObjectsInBackground { (dateObjects, error) in
            if let dateObjects = dateObjects {
                var eventDate = dateObjects[0]
                var relation = eventDate.relation(forKey: "events")
                relation.query().findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        //objects should be events for a particular date
                        self.events = objects.map {Event.create(from: $0)}
                    }
                }
            }
    }

/*
        self.request = PFQuery(className: "EventObject");
        //self.request?.whereKey("dates", equalTo: date2)
        self.lastRequest = self.request


        if let request = self.request {
            request.findObjectsInBackground(block: { [weak weakSelf = self] (objects, error) in
                guard error == nil else {
                    print (error?.localizedDescription ?? "Error retrieving events from Parse.");
                    return
                }
                guard let objects = objects else { return }
                guard weakSelf?.lastRequest == weakSelf?.request else { return }

                weakSelf?.events = objects.map {Event.create(from: $0)}
            })
        }
*/
    }

    private func setUpNavigationBar() {
        let newColor = UIColor(red: 255, green: 147, blue: 92)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = newColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationController?.editButtonItem = backItem
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
    }

    //MARK: PFLogInViewXontrollerDelegate functions

    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        dismiss(animated: true, completion: nil)
    }

    //To-Do: Need to handle error conditions
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        self.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Facebook LogIn Failed", message: "Facebook login failed due to an error. We skipped the login step for you. Enjoy Kiddo!", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }

    //To-Do: Can't trigger cancel call. Need to look into this.
    //Skip log in triggers this.
    func logInViewControllerDidCancelLog(in logInController: PFLogInViewController) {
        self.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Facebook LogIn Skipped", message: "You have chosen to skip the Facebook login.", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }


    
    @IBAction func switchButtonPressed(_ sender: UISegmentedControl) {
        self.timelineTableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDetailView" {
            let selectedIndex = timelineTableView.indexPathForSelectedRow!.row
            let selectedEvent = self.events[selectedIndex]
            let currentCell = timelineTableView.cellForRow(at: timelineTableView.indexPathForSelectedRow!)! as! EventTableViewCell

            if let destinationViewController = segue.destination as? DetailViewController {
                destinationViewController.event = selectedEvent
                destinationViewController.image = currentCell.eventImage?.image
            }
        }
    }
}

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if switchControl.selectedSegmentIndex == 0 {
            return events.count
        } else {
            return eventsTomorrow.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var tempArray = [Event]()

        //0 means today, 1 means tomorrow
        if switchControl.selectedSegmentIndex == 0 {
            tempArray = events
        } else {
            tempArray = eventsTomorrow
        }

        let cell = self.timelineTableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier(), for: indexPath) as! EventTableViewCell

        let currentEvent = tempArray[indexPath.row]
        cell.event = currentEvent

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: nil)

    }
}
