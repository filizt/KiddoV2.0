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

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    var events = [Event]() {
        didSet {
            self.timelineTableView.reloadData()
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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

        self.segmentedControl.items = ["TODAY","TOMORROW","LATER"]

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.backgroundColor = UIColor.gray
    }

    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
         self.getEvents()
    }

    private var lastRequest: PFQuery<PFObject>?

    private func getEvents() {
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
                        self.activityIndicator.stopAnimating()
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
        navigationController?.navigationBar.backgroundColor = newColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationController?.editButtonItem = backItem
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
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
        return events.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var tempArray = [Event]()

        //0 means today, 1 means tomorrow

        tempArray = events


        let cell = self.timelineTableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier(), for: indexPath) as! EventTableViewCell

        let currentEvent = tempArray[indexPath.row]
        cell.event = currentEvent

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: nil)

    }
}
