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
import UserNotifications

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomSegmentedControlDelegate {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var request:PFQuery<PFObject>?

    private var today = [Event]() {
        didSet {
            if self.today.elementsEqual(oldValue, by: { $0.id == $1.id }) {
                today = oldValue
            }
        }
    }
    private var tomorrow = [Event]()
    private var later = [Event]()

    private var events = [Event]() {
        didSet {
            if !self.events.elementsEqual(oldValue, by: { $0.id == $1.id }) {
                self.events.sort { ($0.startTime < $1.startTime) }
                animateTableViewReload()
            }
        }
    }


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
        self.segmentedControl.delegate = self

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.backgroundColor = UIColor.gray

        UNUserNotificationCenter.current().getPendingNotificationRequests { (pendingNotifications) in
            for notification in pendingNotifications {
                print("notification", notification)
            }
        }

        //UIApplication.shared.sche

    }


    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        self.fetchAllEvents()
    }

    
    private var lastRequest: PFQuery<PFObject>?

    private func fetchAllEvents() {
        let eventDateQuery = PFQuery(className: "EventDate")
        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
        eventDateQuery.whereKey("eventDate", equalTo: date)
        eventDateQuery.findObjectsInBackground { (dateObjects, error) in
            if let dateObjects = dateObjects {
                var relation = dateObjects[0].relation(forKey: "events")
                relation.query().findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        //objects should be events for a particular date
                        let returnedEvents = objects.map { Event.create(from: $0) }
                        self.today = returnedEvents
                        if self.segmentedControl.selectedIndex == 0 {
                            self.events = self.today
                        }
                    self.activityIndicator.stopAnimating()
                    }
                }
            }
        }

        let queryTomorrow = PFQuery(className: "EventDate")
        let dateTomorrow = DateUtil.shared.createDate(from: DateUtil.shared.tomorrow())
        queryTomorrow.whereKey("eventDate", equalTo: dateTomorrow)
        queryTomorrow.findObjectsInBackground { (dateObjects, error) in
            if let dateObjects = dateObjects {
                var relation = dateObjects[0].relation(forKey: "events")
                relation.query().findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        //objects should be events for a particular date
                        let returnedEvents = objects.map {Event.create(from: $0)}
                        if !self.tomorrow.elementsEqual(returnedEvents, by: { $0.id == $1.id }) {
                            self.tomorrow = returnedEvents
                            if self.segmentedControl.selectedIndex == 1 {
                                self.events = self.tomorrow
                            }
                        }
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }



        let queryLater = PFQuery(className: "EventObject")
        guard let laterDate = DateUtil.shared.later() else { return }
        queryLater.whereKey("allEventDates", greaterThanOrEqualTo: laterDate)
        queryLater.limit = 20
        queryLater.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                let returnedEvents = objects.map { Event.create(from: $0) }
                    if !self.later.elementsEqual(returnedEvents, by: { $0.id == $1.id }) {
                        self.later = returnedEvents
                        if self.segmentedControl.selectedIndex == 2 {
                            self.events = self.later
                        }
                    }
                    self.activityIndicator.stopAnimating()
            }
        }
    }

    private func setUpNavigationBar() {
        let newColor = UIColor(red:0.25, green:0.18, blue:0.35, alpha:1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = newColor
        navigationController?.navigationBar.backgroundColor = newColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        navigationController?.navigationBar.topItem?.title = "EVENTS FOR"

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedEvent = self.events[indexPath.row]
        let cell = self.timelineTableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier(), for: indexPath) as! EventTableViewCell
        cell.event = selectedEvent

        if self.segmentedControl.selectedIndex == 2 {
            cell.eventStartTime.text = DateUtil.shared.fullDateString(from: selectedEvent.date)
        }
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: nil)

    }

    func didSelectItem(sender: CustomSegmentedControl, selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self.events = self.today
        case 1:
            self.events = self.tomorrow
        case 2:
            self.events = self.later
        default:
            self.events = self.today
        }
    }

    private func animateTableViewReload() {
        UIView.transition(with: timelineTableView,
                      duration: 0.25,
                       options: .transitionCrossDissolve,
                    animations: { () -> Void in
                                    self.timelineTableView.reloadData()
                                },
                    completion: { (completed: Bool) in
                                    if (completed) {
                                        if self.events.count > 0 {
                                            if let visibleIndexPaths = self.timelineTableView.indexPathsForVisibleRows {
                                                let x = IndexPath(item: 0, section: 0)
                                                if !visibleIndexPaths.contains(x) {
                                                    self.timelineTableView.scrollToRow(at: x, at: UITableViewScrollPosition.top, animated: true)
                                                }
                                            }
                                        }
                                    }
                                });
    }

}
