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
import Crashlytics

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomSegmentedControlDelegate  {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var request:PFQuery<PFObject>?

    private var events = [Event]() {
        didSet {
            if !self.events.elementsEqual(oldValue, by: { $0.id == $1.id }) {
                timelineTableView.reloadData()
                timelineTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                animateTimelineCells()
            }
        }
    }

    private var today = [Event]()
    private var tomorrow = [Event]()
    private var later = [Event]() {
        didSet {
            if self.later.elementsEqual(oldValue, by: { $0.id == $1.id }) {
                later = oldValue
            }
        }
    }

    var loginFailAlert: UIAlertController? {
        get {
            if loginFailed {
                let alert = UIAlertController(title: "Facebook Login Skipped", message: "No login required - let's find some fun events!", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil )
                alert.addAction(alertAction)
                return alert
            } else {
                return nil
            }
        }
    }

    var loginFailed: Bool = false

    func animateTimelineCells() {

        let visibleCells = timelineTableView.visibleCells.map { (cell) -> EventTableViewCell in
            cell.transform = CGAffineTransform(translationX: 0, y: timelineTableView.bounds.size.height)
            return cell as! EventTableViewCell
        }

        var index = 0

        for cell in visibleCells {
            UIView.animate(withDuration: 0.50, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform =  CGAffineTransform.identity
            })
            index += 1
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
        self.timelineTableView.separatorStyle = .none

        self.setUpNavigationBar()

        self.segmentedControl.items = ["TODAY","TOMORROW","LATER"]
        self.segmentedControl.delegate = self

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray


        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.requestAuthForNotifications), userInfo: nil, repeats: false);

        if let alert = self.loginFailAlert {
            self.present(alert, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        //First time the app loads, default view is today tab. Let's log that.
        Answers.logContentView(withName: "Today Tab", contentType: nil, contentId: nil, customAttributes: nil)
        Answers.logCustomEvent(withName: "App Launch", customAttributes:nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func didBecomeActive() {
        activityIndicator.startAnimating()
        self.fetchAllEvents()

    }

    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        self.fetchAllEvents()
    }

   
    //MARK: Local Notifications

    func requestAuthForNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus != .authorized {
                if self.notificationsAuthNeeded() {
                    UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound]) {(granted, error) in
                        if granted {
                            //schedule notifications.
                            self.scheduleLocalNotifications()
                            Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Authroized"])
                        } else {
                            UserDefaults.standard.set(Date(), forKey: "UserNotificationsDeniedKey")
                            Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Denied"])
                        }
                    }
                }
            }
        })
    }

    func notificationsAuthNeeded() -> Bool {
        if let lastNotificationAuthRequest = UserDefaults.standard.object(forKey: "UserNotificationsDeniedKey") as? Date {
            guard ((lastNotificationAuthRequest.timeIntervalSinceNow * -1) <= (60*60*24*3)) else { return false }
        }

        return true //first time user case
    }


    func scheduleLocalNotifications() {
        //time interval is every 3 days
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*24*3), repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Kiddo"
        content.body = "Kiddo has some new things for you and the littles - come check them out!"
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    //MARK: Fetch Events

    private var lastRequest: PFQuery<PFObject>?

    private func fetchAllEvents() {
        let eventDateQuery = PFQuery(className: "EventDate")
        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
        eventDateQuery.whereKey("eventDate", equalTo: date)
        eventDateQuery.findObjectsInBackground { (dateObjects, error) in
            if let dateObjects = dateObjects {
                let relation = dateObjects[0].relation(forKey: "events")
                relation.query().findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        //objects should be events for a particular date
                        let returnedEvents = objects.map { Event.create(from: $0) }
                        let sortedEvents = self.sortEvents(events: returnedEvents)
                        self.today = sortedEvents
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
                let relation = dateObjects[0].relation(forKey: "events")
                relation.query().findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        //objects should be events for a particular date
                        let returnedEvents = objects.map {Event.create(from: $0)}
                        let sortedEvents = self.sortEvents(events: returnedEvents)
                        self.tomorrow = sortedEvents
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
                var returnedEvents = objects.map { Event.create(from: $0) }
                    if !self.later.elementsEqual(returnedEvents, by: { $0.id == $1.id }) {
                        for i in 0..<returnedEvents.count {
                            returnedEvents[i].updateDates(bydate: laterDate)
                        }
                        self.later = returnedEvents.sorted { $0.dates.first! < $1.dates.first! }
                    }
                    self.activityIndicator.stopAnimating()
            }
        }
    }

    func sortEvents(events: [Event]) -> [Event]{
        var e = events
        var a = e.filter { $0.allDayFlag == false }
        let b = e.filter { $0.allDayFlag == true }
        a.sort { ($0.startTime < $1.startTime) }
        e = a + b

        return e
    }


    //MARK: Stup Navigation Bar

    private func setUpNavigationBar() {
        let newColor = UIColor(red:0.25, green:0.18, blue:0.35, alpha:1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = newColor
        navigationController?.navigationBar.backgroundColor = newColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        navigationController?.navigationBar.topItem?.title = "PLANS FOR"

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

    //MARK: TableView Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedEvent = self.events[indexPath.row]
        let cell = self.timelineTableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier(), for: indexPath) as! EventTableViewCell
        cell.event = selectedEvent

        if self.segmentedControl.selectedIndex == 2 {
            cell.eventStartTime.text = DateUtil.shared.shortDateString(from: selectedEvent.dates.first!)
        }
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: nil)

    }

    //MARK: Segmented Control Delegate

    func didSelectItem(sender: CustomSegmentedControl, selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self.events = self.today
            Answers.logContentView(withName: "Today Tab", contentType: nil, contentId: nil, customAttributes: nil)
        case 1:
            self.events = self.tomorrow
             Answers.logContentView(withName: "Tomorrow Tab", contentType: nil, contentId: nil, customAttributes: nil)
        case 2:
            self.events = self.later
             Answers.logContentView(withName: "Later Tab", contentType: nil, contentId: nil, customAttributes: nil)
        default:
            self.events = self.today
        }
    }
}
