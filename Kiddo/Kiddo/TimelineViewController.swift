//
//  TimeLineViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import UserNotifications
import Crashlytics
import ParseFacebookUtilsV4

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomSegmentedControlDelegate  {

    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var request:PFQuery<PFObject>?

    private var events = [Event]() {
        didSet {
            if events.count > 0 {
                timelineTableView.reloadData()
                timelineTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                animateTimelineCells()
            }
        }
    }
    private var today = [Event]() {
        didSet {
            if today.count > 0 {
                today = self.sortEventsSham(events: today )

                if self.segmentedControl.selectedIndex == 0 {
                    self.events = self.today
                }
            }
        }
    }
    private var tomorrow = [Event]() {
        didSet {
            if tomorrow.count > 0 {
                tomorrow = self.sortEventsSham(events: tomorrow )
            }
        }
    }
    private var later = [Event]() {
        didSet {
            if later.count > 0 {
                guard let laterDate = DateUtil.shared.later() else { return }
                for i in 0..<later.count {
                    later[i].updateDates(bydate: laterDate)
                }
                later.sort { $0.dates.first! < $1.dates.first! }
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
        self.timelineTableView.separatorStyle = .none

        self.setUpNavigationBar()

        self.segmentedControl.items = ["TODAY","TOMORROW","LATER"]
        self.segmentedControl.delegate = self

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        NotificationCenter.default.addObserver(self, selector: #selector(applationEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        //First time the app loads, default view is today tab. Let's log that.
        Answers.logContentView(withName: "Today Tab", contentType: nil, contentId: nil, customAttributes: nil)
        Answers.logCustomEvent(withName: "App Launch", customAttributes:nil)

        activityIndicator.startAnimating()
        self.fetchAllEvents()

        updateUserGraphDataIfNecessary()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    override func viewWillAppear(_ animated: Bool) {

    }


    func applationEnteredForeground() {
        activityIndicator.startAnimating()
        self.fetchAllEvents()

        self.updateUserGraphDataIfNecessary()
    }

    func updateUserGraphDataIfNecessary() {
        //user had signed up through FB before and currently logged in.
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            let query = PFQuery(className: "UserGraphInfo")
            query.whereKey("parseUserId", equalTo: currentParseUserObjectId)
            query.getFirstObjectInBackground() { (object, error) in
                if let object = object {
                    //user graph data already saved, just update the lastSeen field
                    object["lastSeen"] = Date()
                    object.saveInBackground()
                } else { //below is the case where users signed up with facebook but we don't have their userGraph info yet
                    if let accessToken = FBSDKAccessToken.current() {
                        PFFacebookUtils.logInInBackground(with: accessToken) { (user, error) in
                            guard error == nil else { print("\(error?.localizedDescription)"); return }
                            if user != nil {
                                let requestParameters = ["fields": "id, first_name, last_name, email, age_range, gender, locale"]
                                if let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters){
                                    userDetails.start { (connection, result, error) -> Void in
                                        guard error == nil else { print("\(error?.localizedDescription)"); return }

                                        if let result = result {
                                            let userGraphObject = UserGraph.create(from: result)
                                            let userInfo: PFObject = PFObject(className: "UserGraphInfo")
                                            userInfo["facebookId"] = userGraphObject.id
                                            userInfo["firstName"] = userGraphObject.first_name
                                            userInfo["lastName"] = userGraphObject.last_name
                                            userInfo["email"] = userGraphObject.email
                                            userInfo["gender"] = userGraphObject.gender
                                            userInfo["locale"] = userGraphObject.locale
                                            userInfo["parseUser"] = PFUser.current()
                                            userInfo["parseUserId"] = PFUser.current()?.objectId
                                            userInfo["lastSeen"] = Date()

                                            userInfo.saveInBackground()
                                        } else {
                                            print("Uh oh. There was an problem getting the  in.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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
   
 
    //MARK: Fetch Events

    private var lastRequest: PFQuery<PFObject>?

    private func fetchAllEvents() {
        let eventToday = PFQuery(className: "EventDate")
        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
        eventToday.whereKey("eventDate", equalTo: date)
        eventToday.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                let relation = dateObjects[0].relation(forKey: "events")
                let query = relation.query()
                query.includeKey("isActive")
                query.whereKey("isActive", equalTo: true)
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        weakSelf?.today = objects.map { Event.create(from: $0) }
                        weakSelf?.activityIndicator.stopAnimating()
                    }
                }
            }
        }

        let queryTomorrow = PFQuery(className: "EventDate")
        let dateTomorrow = DateUtil.shared.createDate(from: DateUtil.shared.tomorrow())
        queryTomorrow.whereKey("eventDate", equalTo: dateTomorrow)
        queryTomorrow.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching tomorrow's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                let relation = dateObjects[0].relation(forKey: "events")
                let query = relation.query()
                query.includeKey("isActive")
                query.whereKey("isActive", equalTo: true)
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        weakSelf?.tomorrow = objects.map { Event.create(from: $0) }
                    }
                }
            }
        }

        let queryLater = PFQuery(className: "EventObject")
        var laterDates = [Date]()
        guard let laterDate = DateUtil.shared.later() else { return }
        guard let laterDatePlusOne = DateUtil.shared.laterPlusOne() else { return }
        laterDates.append(laterDate)
        laterDates.append(laterDatePlusOne)
        queryLater.whereKey("allEventDates", containedIn: laterDates)
        queryLater.whereKey("isActive", equalTo: true)
        queryLater.limit = 10
        queryLater.findObjectsInBackground { [weak weakSelf = self] (objects, error) in
            guard error == nil else {
                print ("Error fetching later events from Parse")
                return
            }

            if let objects = objects {
                weakSelf?.later = objects.map { Event.create(from: $0) }

                let queryPopular = PFQuery(className: "EventObject")
                guard let date: Date = DateUtil.shared.laterPlusOne() else { return }
                queryPopular.whereKey("allEventDates", greaterThanOrEqualTo: date)
                queryPopular.whereKey("isActive", equalTo: true)
                queryPopular.whereKey("isPopular", equalTo: true)
                queryPopular.limit = 12
                queryPopular.findObjectsInBackground { [weak weakSelf = self] (popularObjects, error) in
                    if let popularObjects = popularObjects {
                        let returnedEvents = popularObjects.map { Event.create(from: $0) }
                        //let's add returned events and dedupe  if necessary - this is a rare condition but still we need to do it.
                        var filteredList = [Event]()
                        for event in returnedEvents {
                            let filtered = weakSelf?.later.filter{ $0.id == event.id }
                            if filtered?.count == 0 {
                                filteredList.append(event)
                            }
                        }
                        weakSelf?.later += filteredList
                    }
                }
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

    // There is first conversion of the string to date object and then sort. This needs to be fixed as some point. We can startTime and endTime as Date() objects.
    func sortEventsSham(events: [Event]) -> [Event]{
        var e = events
        let a = e.filter { $0.featuredFlag == true }
        let aComplement = e.filter { $0.featuredFlag == false }
        var b = aComplement.filter { $0.allDayFlag == false }
        let c = aComplement.filter { $0.allDayFlag == true }

        b.sort { (DateUtil.shared.createShortTimeDate(from: $0.startTime)).compare(DateUtil.shared.createShortTimeDate(from: $1.startTime)) == ComparisonResult.orderedAscending }
        e = a + b + c

        return e
    }


    //MARK: Setup Navigation Bar
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
                destinationViewController.currentTab = TabBarItems(rawValue: segmentedControl.selectedIndex)
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
            cell.eventFeaturedStar.isHidden = true
            cell.eventFeaturedLabel.isHidden = true
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
