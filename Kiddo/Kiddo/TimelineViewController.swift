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
import MapKit
import Cluster
import ForecastIO
import Mixpanel

class EventAnnotation : Annotation {
    var event : Event!
}


class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomSegmentedControlDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CellFilterButtonDelegate {

    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var request:PFQuery<PFObject>?
    private var lastModified: Date?
    let clusterManager = ClusterManager()
    //"❄️ Holiday"
    fileprivate var filters = ["ALL","📍 Nearby","🐝 Keep'em Busy", "🍀 Free","🌕 Indoor"]

    fileprivate var userLocationFound = false
    var lastKnownUserLocation : CLLocation? {
        didSet {
            if oldValue != nil {
                //this is not first time
                if let distance = oldValue?.distance(from: lastKnownUserLocation!) {
                    if !distance.isLessThanOrEqualTo(5000.0) {
                        print("distance in greater than 5000")
                        self.getWeatherForecast()
                    }
                }
            } else {
                //first time
                self.getWeatherForecast()
            }
        }
    }

    fileprivate var firstTimeLaunch = true

    //this is beautiful! No need to make locationManager optional to overcome first time problems (calls the didChangeAuthorization delegate when the locationManager is created, before asking the user for auth)
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1000.0
        return manager
    }()

    var currentForecast: DataPoint? {
        didSet {
            let setView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            if let currentForecastWeatherIcon = currentForecast?.icon?.rawValue {
                imageView.image = UIImage(named: currentForecastWeatherIcon)
                //need a bit fine tuning for the switch cases of below
                switch currentForecastWeatherIcon {
                case "clear-day":
                    if let cloudCoverRate = currentForecast?.cloudCover {
                        imageView.image = UIImage(named: (cloudCoverRate > 0.2) ? "partly-cloudy-day": "clear-day" )
                    }
                case "partly-cloudy-day":
                    if let cloudCoverRate = currentForecast?.cloudCover {
                        imageView.image = UIImage(named: (cloudCoverRate > 0.4) ? "cloudy" : "partly-cloudy-day" )
                    }
                case "rain":
                    if let rainIntensity = currentForecast?.precipitationIntensity {
                        imageView.image = UIImage(named: (rainIntensity > 1.50) ? "sleet" : "rain" )
                    }
                default:
                break
                }
            }

            let label = UILabel(frame: CGRect(x: 35, y: 0, width: 50, height: 33))
            label.text = String(Int((self.currentForecast?.temperature ?? 0 ))) + "°F" //"Seattle 46°F"
            label.textColor = UIColor.white
            label.font = UIFont(name: "Avenir-Medium", size: 17)
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            setView.addSubview(label)
            setView.addSubview(imageView)

            let barButton = UIBarButtonItem.init(customView: setView)
            self.navigationItem.setLeftBarButton(barButton, animated: true)
        }
    }

    fileprivate var events = [Event]() {
        didSet {
            if events.count > 0 {
                if isListSelected {
                    timelineTableView.reloadData()
                    timelineTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    animateTimelineCells()
                } else {
                    if let map = mapView {
                        map.removeAnnotations(map.annotations)
                        clusterManager.remove(clusterManager.annotations)
                        clusterManager.zoomLevel = 17

                        for event in events{
                            if let location = event.geoLocation {
                                let annotation = EventAnnotation()
                                annotation.event = event
                                annotation.coordinate = location.location()
                                annotation.type = .color(UIColor(red:0.90, green:0.29, blue:0.24, alpha:1.0), radius: 30) // .image(UIImage(named: "pin"))
                                annotation.title = event.title + " @ " + event.location
                                if segmentedControl.selectedIndex == 2 {
                                    annotation.subtitle = DateUtil.shared.fullDateString(from: event.startTime)
                                } else {
                                    annotation.subtitle = DateUtil.shared.shortTimeString(from: event.startTime)
                                }

                                clusterManager.add(annotation)

                                var zoomRect = MKMapRectNull
                                for annotation in clusterManager.annotations {
                                    let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                                    let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                                    if MKMapRectIsNull(zoomRect) {
                                        zoomRect = pointRect
                                    } else {
                                        zoomRect = MKMapRectUnion(zoomRect, pointRect)
                                    }
                                }

                                zoomRect = MKMapRectMake(zoomRect.origin.x - zoomRect.size.width * 0.1 , zoomRect.origin.y - zoomRect.size.height * 0.1, zoomRect.size.width * 1.2, zoomRect.size.height * 1.2)
                                clusterManager.reload(map, visibleMapRect: zoomRect)
                                map.setVisibleMapRect(zoomRect, animated: true)
                            }
                        }
//                        for annotation in clusterManager.annotations {
//                            map.addAnnotation(annotation)
//                        }
//                        map.showAnnotations(map.annotations, animated: true)
                    }
                }
            }
        }
    }

    fileprivate var today = [Event]() {
        didSet {
            if today.count > 0 {
                today = self.sortEvents(events: today)

                if firstTimeLaunch == true {
                    firstTimeLaunch = false
                    self.events = self.today
                } else {
                    if oldValue.count != today.count && segmentedControl.selectedIndex == 0 {
                        reloadDataAndUpdateUI()
                    }
                }
            }
        }
    }

    fileprivate var tomorrow = [Event]() {
        didSet {
            if tomorrow.count > 0 {
                tomorrow = self.sortEvents(events: tomorrow )

                if oldValue.count != tomorrow.count && segmentedControl.selectedIndex == 1 {
                    reloadDataAndUpdateUI()
                }
            }
        }
    }

    fileprivate var later = [Event]() {
        didSet {
            if later.count > 0 {
                //guard let laterDate = DateUtil.shared.laterStart() else { return }
//                for i in 0..<later.count {
//                    later[i].updateDates(bydate: laterDate)
//                }
                later.sort { $0.eventDates.first! < $1.eventDates.first! }

                if oldValue.count != later.count && segmentedControl.selectedIndex == 2 {
                    reloadDataAndUpdateUI()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapBarButtonItem = UIBarButtonItem(image: UIImage(named: "mapIcon")!, style: .done, target: self, action: #selector(switchViewType))
        self.navigationItem.rightBarButtonItem = mapBarButtonItem

        //if we already recorded the last know location retrieve
        if let locationDictionary = UserDefaults.standard.object(forKey: "lastLocation") as? Dictionary<String,CLLocationDegrees> {
            let locationLat = locationDictionary["lat"]!
            let locationLon = locationDictionary["lon"]!
            lastKnownUserLocation = CLLocation(latitude: locationLat, longitude: locationLon)
        } else {
             self.getWeatherForecast()// will get it for defaut location - Seattle.
        }

        mapContainerView.alpha = 0
        mapContainerView.isHidden = true

        self.timelineTableView.dataSource = self
        self.timelineTableView.delegate = self

        let nib = UINib(nibName: "eventCell", bundle: Bundle.main)
        self.timelineTableView.register(nib, forCellReuseIdentifier: EventTableViewCell.identifier())
        
        self.timelineTableView.estimatedRowHeight = 100
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        self.timelineTableView.separatorStyle = .none

        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self

        self.setUpNavigationBar()

        self.segmentedControl.items = ["TODAY","TOMORROW","LATER"]
        self.segmentedControl.delegate = self

//        if SeasonalEvent.shared.isEnabled == true {
//            filters.insert(SeasonalEvent.shared.name, at: 2)
//        }

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
//        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        //First time the app loads, default view is today tab. Let's log that.
        Answers.logContentView(withName: "Today Tab", contentType: nil, contentId: nil, customAttributes: nil)
        Answers.logCustomEvent(withName: "App Launch", customAttributes:nil)

        activityIndicator.startAnimating()
        self.fetchAllEvents()
        self.setLastModified()
        self.self.fetchPhotosIfNecessary()

        if let currentUser = PFUser.current() {
            Mixpanel.mainInstance().people.set(properties: ["ParseUserId": currentUser.objectId ?? "" ])
        }

        Mixpanel.mainInstance().people.increment(property: "Number of App Launches", by: 1.0)

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
       self.deepLinkHandler()
       showStatusBar(style: .lightContent)

    }

    override func viewDidAppear(_ animated: Bool) {
        let selectedCells = filtersCollectionView.visibleCells.filter{ $0.isSelected == true }

        if selectedCells.count < 1 {
            resetCollectionViewSelection()
        }

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    private func updateAndRefreshAllIfNeeded() {
        //Check if we're coming back from detail view spawned switches

        //if so do nothing

        //if not, update all data, reset filter views, etc.
        self.fetchAllEvents()

    }

    private func getWeatherForecast() {
        //For now, longitude latitude hard coded for Seattle.
        var location = CLLocation(latitude: 47.6205, longitude: -122.3493)

        if let lastKnown = lastKnownUserLocation {
            location = lastKnown
        }

        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.forecastIO.getForecast(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak weakSelf = self] result in
            switch result {
            case .success(let forecast, let requestMetadata):
                if let currForecast = forecast.currently{
                    DispatchQueue.main.async {
                        weakSelf?.currentForecast = currForecast
                    }
                }
                break
            case .failure(let error):
                //  Uh-oh. We have an error!
                break
            }
        }
    }

    private func reloadDataAndUpdateUI() {
        //get current state of segmented control
        //get current state of filters
        //update tableview

        let selectedCells = filtersCollectionView.visibleCells.filter{ $0.isSelected == true }

        if let sc = selectedCells.first as? FilterCollectionViewCell {
            sc.layoutIfNeeded()
        }
    }

    private func resetCollectionViewSelection() {
        //filtersCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        filtersCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.left)
    }

    func recordUserFilterAction(forFilter: String) {
        let userInfo: PFObject = PFObject(className: "UserTimelineFilterHistory")
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = PFUser.current()?.objectId
        } else if let email = UserDefaults.standard.object(forKey: "email") as? String { //where user didn't log in with FB but used their email to sign up
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
            userInfo["email"] = email
        }

        userInfo["filter"] = forFilter
        userInfo["day"] = segmentedControl.selectedIndex
        userInfo.saveInBackground()
    }

    func recordUserSegmentedControlAction(forDay: String) {
        let userInfo: PFObject = PFObject(className: "UserTimelineDayHistory")
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = PFUser.current()?.objectId
        } else if let email = UserDefaults.standard.object(forKey: "email") as? String { //where user didn't log in with FB but used their email to sign up
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
            userInfo["email"] = email
        }

        userInfo["day"] = forDay
        userInfo.saveInBackground()
    }


    func showFiltersView() {
        self.performSegue(withIdentifier: "showFilterOptions", sender: nil)
    }

    func deepLinkHandler() {
       if let eventId = Event.pushedEventId {
            let query = PFQuery(className:"Event")
            query.getObjectInBackground(withId: eventId) {(event, error) -> Void in
                guard error == nil else {
                    print ("Error retrieving data from Parse")
                    return
                }
                if let event = event {
                    Event.pushedEvent = Event.create(from: event, forDay: "PushedEvent")
                    self.performSegue(withIdentifier: "showDetailViewForPushedEvent", sender: nil)
                }
            }
        }
    }

    //when to call fetch events - this is too generic of a call
    //a good way to determine it is to have a timer?
//    func applicationEnteredForeground() {
//        self.activityIndicator.startAnimating()
//        self.fetchAllEvents()
//        self.fetchPhotosIfNecessary()
//
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//        }
//    }

    func setLastModified() {
        let query = PFQuery(className: "EventImage")
        query.order(byDescending: "updatedAt")
        query.getFirstObjectInBackground { (object, error) in
            guard error == nil else {
                print ("Error retrieving image data from Parse")
                return
            }
            if let object = object {
                self.lastModified = object.updatedAt
            }
        }
    }

    func fetchPhotosIfNecessary() {
        let query = PFQuery(className: "EventImage")
        query.order(byDescending: "updatedAt")
        query.getFirstObjectInBackground { (object, error) in
            guard error == nil else {
                print ("Error retrieving image data from Parse")
                return
            }

            if let object = object {
                guard let currentUpdatedAtValue = object.updatedAt else { return }
                if let lastModified = self.lastModified {
                    if (lastModified.timeIntervalSinceNow * -1) > (currentUpdatedAtValue.timeIntervalSinceNow * -1){
                        self.lastModified = currentUpdatedAtValue
                        let queryImageFetch = PFQuery(className: "EventImage")
                        queryImageFetch.limit = SimpleCache.shared.capacity
                        queryImageFetch.findObjectsInBackground(block: { (objects, error) in
                            guard error == nil else {
                                print ("Error retrieving image data from Parse")
                                return
                            }

                            if let objects = objects {
                                for object in objects {
                                    guard let imageFile = object["image"] as? PFFile else { return }

                                    imageFile.getDataInBackground({ (data, error) in
                                        guard error == nil else {
                                            print ("Error retrieving image data from Parse")
                                            return
                                        }
                                        guard let imageData = data else { return }
                                        guard let image = UIImage(data: imageData) else { return }
                                        
                                        SimpleCache.shared.setImage(image, key: object.objectId!)
                                    })
                                }
                            }
                        })
                    }//if backend is updated
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
    //need last request for fetch: today, tomorrow, later 

    private func fetchAllEvents() {
        self.activityIndicator.startAnimating()
        fetchTodayEvents()
        fetchTomorrrowEvents()
        fetchLaterEvents()

    }

    private func fetchTodayEvents() {
        let startDate = DateUtil.shared.todayStart() //returns a test date
        let endDate = DateUtil.shared.addOneDay(startDate: startDate!) //returns a test date
//        print(startDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: startDate!))
//        print(endDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: endDate!))

        let innerQuery = PFQuery(className: "EventInstance")
        innerQuery.whereKey("eventDate", lessThanOrEqualTo: endDate)
        innerQuery.whereKey("eventDate", greaterThan: startDate)

        let eventsQuery = PFQuery(className: "Event")
        eventsQuery.includeKey("eventInstanceObjects")
        eventsQuery.whereKey("isActive", equalTo: true)
        eventsQuery.whereKey("eventInstanceObjects", matchesQuery: innerQuery)

        var events = [Event]()

        eventsQuery.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                //all the

                weakSelf?.today = dateObjects.map { Event.create(from: $0, forDay: "Today") }
                weakSelf?.activityIndicator.stopAnimating()
            }

        }


//        let eventToday = PFQuery(className: "EventDate")
//        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
//        eventToday.whereKey("eventDate", equalTo: date)
//        eventToday.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
//            guard error == nil else {
//                print ("Error fetching today's events from Parse")
//                return
//            }
//
//            if let dateObjects = dateObjects {
//                let relation = dateObjects[0].relation(forKey: "events")
//                let query = relation.query()
//                query.includeKey("isActive")
//                query.whereKey("isActive", equalTo: true)
//                query.findObjectsInBackground { (objects, error) in
//                    if let objects = objects {
//                        weakSelf?.today = objects.map { Event.create(from: $0) }
//                        weakSelf?.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//        }
    }

    private func fetchTomorrrowEvents() {
//        let queryTomorrow = PFQuery(className: "EventDate")
//        let dateTomorrow = DateUtil.shared.createDate(from: DateUtil.shared.tomorrowString())
//        queryTomorrow.whereKey("eventDate", equalTo: dateTomorrow)
//        queryTomorrow.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
//            guard error == nil else {
//                print ("Error fetching tomorrow's events from Parse")
//                return
//            }
//
//            if let dateObjects = dateObjects {
//                let relation = dateObjects[0].relation(forKey: "events")
//                let query = relation.query()
//                query.includeKey("isActive")
//                query.whereKey("isActive", equalTo: true)
//                query.findObjectsInBackground { (objects, error) in
//                    if let objects = objects {
//                        weakSelf?.tomorrow = objects.map { Event.create(from: $0) }
//                    }
//                }
//            }
//        }

        let startDate = DateUtil.shared.tomorrowStart() //returns a test date
        let endDate = DateUtil.shared.addOneDay(startDate: startDate!) //returns a test date
//        print(startDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: startDate!))
//        print(endDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: endDate!))

        let innerQuery = PFQuery(className: "EventInstance")
        innerQuery.whereKey("eventDate", lessThanOrEqualTo: endDate)
        innerQuery.whereKey("eventDate", greaterThan: startDate)

        let eventsQuery = PFQuery(className: "Event")
        eventsQuery.includeKey("eventInstanceObjects")
        eventsQuery.whereKey("isActive", equalTo: true)
        eventsQuery.whereKey("eventInstanceObjects", matchesQuery: innerQuery)

        var events = [Event]()

        eventsQuery.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                //all the

                weakSelf?.tomorrow = dateObjects.map { Event.create(from: $0, forDay: "Tomorrow") }
            }

        }
    }

    private func fetchLaterEvents() {
        let startDate = DateUtil.shared.laterStart() //returns a test date
        let endDate = DateUtil.shared.addOneDay(startDate: startDate!) //returns a test date
//        print(startDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: startDate!))
//        print(endDate) // this should print PST but the actual date should be UTC.
//        print(DateUtil.shared.dateStringWithDateTimeStyle(from: endDate!))

        let innerQuery = PFQuery(className: "EventInstance")
        innerQuery.whereKey("eventDate", greaterThan: startDate)

        let eventsQuery = PFQuery(className: "Event")
        eventsQuery.includeKey("eventInstanceObjects")
        //add popular check here
        //limit it to 200 or something high
        eventsQuery.whereKey("isActive", equalTo: true)
        eventsQuery.whereKey("isPopular", equalTo: true)
        eventsQuery.limit = 100
        eventsQuery.whereKey("eventInstanceObjects", matchesQuery: innerQuery)

        var events = [Event]()

        eventsQuery.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                weakSelf?.later = dateObjects.map { Event.create(from: $0, forDay: "Later") }
            }

        }

        //let innerQuery = PFQuery(class)

//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myDictionary.myKey = %@", @"mySearchTerm"];
//
//        PFQuery *objectQuery = [PFQuery queryWithClassName:@"myObject" predicate:predicate];



        // Using NSPredicate
//        let innerPred = NSPredicate(format: "image IN SELF")
//        let innerQuery = PFQuery(className: "Post", predicate: innerPred)
//
//        let pred = NSPredicate(format: "eventInstances %@", innerQuery)
//        let query = PFQuery(className: "Comment", predicate: pred)




//        let innerQuery = PFQuery(className: "TestEventObject")
//        innerQuery.whereKey("isActive", equalTo: true)
//
//        let eventToday = PFQuery(className: "TestEventInstance")
//        //eventToday.includeKey("allEventDates")
//        eventToday.whereKey("allEventDates", lessThanOrEqualTo: endDate)
//        eventToday.whereKey("allEventDates", greaterThan: startDate)
//        eventToday.whereKey("eventObject", matchesQuery: innerQuery)

//        let eventQuery = PFQuery(className:"TestEventObject")
//        eventToday.includeKey("allEventDates")
//        eventToday.whereKey("allEventDates", lessThanOrEqualTo: endDate)
//        eventToday.whereKey("allEventDates", greaterThan: startDate)
//
//        let query = PFQuery.orQuery(withSubqueries: [eventQuery])
//        query.whe
//
//        eventToday.
//        eventToday.findObjectsInBackground { [weak weakSelf = self] (dateObjects, error) in
//            guard error == nil else {
//                print ("Error fetching today's events from Parse")
//                return
//            }
//
//            if let dateObjects = dateObjects {
//                //all the
//                print("we're here")
//        }


//        let queryLater = PFQuery(className: "EventObject")
//        var laterDates = [Date]()
//        guard let laterDate = DateUtil.shared.later() else { return }
//        guard let laterDatePlusOne = DateUtil.shared.laterPlusOne() else { return }
//        print(laterDate)
//        print(laterDatePlusOne)
//        laterDates.append(laterDate)
//        laterDates.append(laterDatePlusOne)
//        queryLater.whereKey("allEventDates", containedIn: laterDates)
//        queryLater.whereKey("isActive", equalTo: true)
//        queryLater.whereKey("isPopular", equalTo: true)
//        queryLater.limit = 35
//        queryLater.findObjectsInBackground { [weak weakSelf = self] (objects, error) in
//            guard error == nil else {
//                print ("Error fetching later events from Parse")
//                return
//            }
//
//            if let objects = objects {
//                weakSelf?.later = objects.map { Event.create(from: $0) }

//                let queryPopular = PFQuery(className: "EventObject")
//                guard let date: Date = DateUtil.shared.later() else { return }
//                queryPopular.whereKey("allEventDates", greaterThanOrEqualTo: date)
//                queryPopular.whereKey("isActive", equalTo: true)
//                queryPopular.whereKey("isPopular", equalTo: true)
//                queryPopular.limit = 40
//                queryPopular.findObjectsInBackground { [weak weakSelf = self] (popularObjects, error) in
//                    if let popularObjects = popularObjects {
//                        let returnedEvents = popularObjects.map { Event.create(from: $0) }
//                        //let's add returned events and dedupe  if necessary - this is a rare condition but still we need to do it.
//                        var filteredList = [Event]()
//                        for event in returnedEvents {
//                            let filtered = weakSelf?.later.filter{ $0.id == event.id }
//                            if filtered?.count == 0 {
//                                filteredList.append(event)
//                            }
//                        }
//                        weakSelf?.later += filteredList
//                    }
//                }
//            }
//        }
        
    }

    func filterEventsByCriteria() {
//        let category = EventType.All
//
//        switch category {
//        case .All :
//            print("NoOp")
//        case .Place :
//            //print("Outdoor")
//            self.events = events.filter { $0.categoryKeywords?.contains("Place") == true }
//        case .Event :
//            self.events = events.filter { $0.categoryKeywords?.contains("Event") == true }
//            print("filtered")
//        case .Free :
//            self.events = events.filter { $0.freeFlag == true }
//        }

    }
    

    func sortEvents(events: [Event]) -> [Event]{
        let e = events

        let featured = e.filter { $0.featuredFlag == true }
        let aComplement = e.filter { $0.featuredFlag == false }
        let sorted = aComplement.sorted { ( $0.startTime < $1.startTime ) }

        return featured + sorted
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
                destinationViewController.image = (currentCell.eventImage?.image)!
                destinationViewController.currentTab = TabBarItems(rawValue: segmentedControl.selectedIndex)!
                destinationViewController.lastKnownUserLocation = self.lastKnownUserLocation
                destinationViewController.currentForecast = self.currentForecast
            }
        } else if segue.identifier == "showDetailViewForPushedEvent" {
            if let destinationViewController = segue.destination as? DetailViewController {
                destinationViewController.event = Event.pushedEvent
                destinationViewController.image = SimpleCache.shared.image(key: (Event.pushedEvent?.imageObjectId)!)
                destinationViewController.currentTab = TabBarItems.none
                destinationViewController.currentForecast = self.currentForecast
                Event.pushedEvent = nil
                Event.pushedEventId = nil
                Event.pushedEventForDateTime = nil
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
            cell.eventStartTime.text = DateUtil.shared.fullDateString(from: selectedEvent.eventDates.first!)
            cell.eventFeaturedStar.isHidden = true
            cell.eventFeaturedLabel.isHidden = true
            cell.eventEndTime.isHidden = true
            cell.dashBetweenTimes.isHidden = true
        }

        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: nil)
    }

    //MARK: Segmented Control Delegate
    var allCell: UICollectionViewCell?
    var testBool = false
    func didSelectItem(sender: CustomSegmentedControl, selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self.events = self.today
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let leftOffset = CGPoint(x: 0, y: 0);
                self.filtersCollectionView.contentOffset = leftOffset
            }) { (finished) -> Void in
                self.resetCollectionViewSelection()
            }
            recordUserSegmentedControlAction(forDay: "Today")
            Answers.logContentView(withName: "Today Tab", contentType: nil, contentId: nil, customAttributes: nil)
        case 1:
            self.events = self.tomorrow
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let leftOffset = CGPoint(x: 0, y: 0);
                self.filtersCollectionView.contentOffset = leftOffset
            }) { (finished) -> Void in
                self.resetCollectionViewSelection()
            }
            Answers.logContentView(withName: "Tomorrow Tab", contentType: nil, contentId: nil, customAttributes: nil)
            recordUserSegmentedControlAction(forDay: "Tomorrow")
        case 2:
            self.events = self.later
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let leftOffset = CGPoint(x: 0, y: 0);
                self.filtersCollectionView.contentOffset = leftOffset
            }) { (finished) -> Void in
                self.resetCollectionViewSelection()
            }
            Answers.logContentView(withName: "Later Tab", contentType: nil, contentId: nil, customAttributes: nil)
            recordUserSegmentedControlAction(forDay: "Later")
        default:
            self.events = self.today
        }
    }

    // MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        cell.setFilterLabel(title: filters[indexPath.row])
        cell.delegate = self

        return cell
    }


    // MARK: Filter Cell Delegate
    // ["All","Nearby","Holiday","Free","Indoor","Arts"]
    func handleFilterButtonTap(selectedFilter: String) {
        var e = [Event]()

        let selectedIndex = self.segmentedControl.selectedIndex
        switch selectedIndex {
        case 0:
            e = self.today
        case 1:
            e = self.tomorrow
        case 2:
            e = self.later
        default:
            e = self.today
        }

        switch selectedFilter {
        case "ALL": //ALL
            self.events = e
            recordUserFilterAction(forFilter: "All")
        case "📍 Nearby": //Nearby
            recordUserFilterAction(forFilter: "Nearby")

            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                //locationManager.requestLocation()
                //execution moves to requestLocation
                self.userLocationFound = false
                locationManager.startUpdatingLocation()
            } else if CLLocationManager.authorizationStatus() == .denied {
                let alertController = UIAlertController (title: "Hmm", message: "It looks like we don't know your location. You can turn on location services in the Settings page.", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                present(alertController, animated: true, completion: nil)
            } else {
                locationManager.requestWhenInUseAuthorization()
            }

            if mapView?.isHidden == false {
                self.mapView?.showsUserLocation = true
            }

        case "🐝 Keep'em Busy": //Holiday
            let filteredEvents = e.filter { $0.categoryKeywords?.contains("Activity") == true }
            if filteredEvents.count > 0 {
                self.events = filteredEvents
                recordUserFilterAction(forFilter: "Keep'em Busy")
            } else {
                let alertController = UIAlertController (title: "Sorry", message: "It looks like we can't find any Keep'em Busy events for the day.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
                    self.resetCollectionViewSelection()
                    self.events = e
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        case "🍀 Free": //Free
            let eventsFiltered = e.filter { $0.freeFlag == true }
            if eventsFiltered.count == 0 {
                let alertController = UIAlertController (title: "Sorry", message: "It looks like we can't find any Free events for the day.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
                    self.resetCollectionViewSelection()
                    self.events = e
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.events = eventsFiltered
                recordUserFilterAction(forFilter: "Free")
            }
        case "🌕 Indoor": //Indoor
            let eventsFiltered = e.filter { $0.categoryKeywords?.contains("Indoor") == true }
            if eventsFiltered.count == 0 {
                let alertController = UIAlertController (title: "Sorry", message: "It looks like we can't find any Indoor events for the day.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
                    self.resetCollectionViewSelection()
                    self.events = e
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.events = eventsFiltered
                recordUserFilterAction(forFilter: "Indoor")
            }

        default:
//            if SeasonalEvent.shared.isEnabled == true {
//                let seasonalFilteredEvents = e.filter { $0.categoryKeywords?.contains(SeasonalEvent.shared.name) == true }
//                if seasonalFilteredEvents.count > 0 {
//                    self.events = seasonalFilteredEvents
//                    recordUserFilterAction(forFilter: SeasonalEvent.shared.name)
//                } else {
//                    let alertController = UIAlertController (title: "Sorry", message: "It looks like we can't find any events for the day.", preferredStyle: .alert)
//                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
//                        self.resetCollectionViewSelection()
//                        self.events = e
//                    }
//                    alertController.addAction(action)
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            } else {
                self.events = e
                recordUserFilterAction(forFilter: "Default")
//            }
        }
    }

    // MARK: Map or List Switching

    @IBOutlet weak var mapContainerView: UIView!
    fileprivate var mapView : MKMapView?
    var isListSelected = true

    func switchViewType(){
        let mapBarButtonItem = UIBarButtonItem(image: UIImage(named: "mapIcon")!, style: .done, target: self, action: #selector(switchViewType))
        let listBarButtonItem = UIBarButtonItem(image: UIImage(named: "listIcon")!, style: .done, target: self, action: #selector(switchViewType))

        isListSelected = !isListSelected
        if isListSelected {
            Answers.logCustomEvent(withName: "Map/List View Toggled", customAttributes: nil)
            self.navigationItem.rightBarButtonItem = mapBarButtonItem
            timelineTableView.isHidden = false
            //didSelectItem(sender: segmentedControl, selectedIndex: segmentedControl.selectedIndex)
            timelineTableView.reloadData()

            UIView.animate(withDuration: 0.5, animations: {
                self.mapContainerView.alpha = 0
                self.timelineTableView.alpha = 1
            }, completion: { (finished) in
                if finished {
                    self.mapContainerView.isHidden = true
                    self.mapView?.removeFromSuperview()
                    self.mapView?.delegate = nil
                    self.mapView = nil
                }
            })
        } else {
            self.navigationItem.rightBarButtonItem = listBarButtonItem
            mapContainerView.isHidden = false
            mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: mapContainerView.frame.size.width, height: mapContainerView.frame.size.height))
            mapView?.delegate = self
            mapView?.showsUserLocation = true
            mapContainerView.addSubview(mapView!)
            reloadMapViewAnnotations()
            //didSelectItem(sender: segmentedControl, selectedIndex: segmentedControl.selectedIndex)

            UIView.animate(withDuration: 0.5, animations: {
                self.mapContainerView.alpha = 1
                self.timelineTableView.alpha = 0
            }, completion: { (finished) in
                if finished {
                    self.timelineTableView.isHidden = true
                }
            })
        }
    }

    private func reloadMapViewAnnotations(){
        if let map = mapView {
            map.removeAnnotations(map.annotations)
            clusterManager.remove(clusterManager.annotations)
            clusterManager.zoomLevel = 17

            for event in events{
                if let location = event.geoLocation {
                    let annotation = EventAnnotation()
                    annotation.event = event
                    annotation.coordinate = location.location()
                    annotation.type = .color(UIColor(red:0.90, green:0.29, blue:0.24, alpha:1.0), radius: 30) // .image(UIImage(named: "pin"))
                    annotation.title = event.title + " @ " + event.location
                    if segmentedControl.selectedIndex == 2 {
                        annotation.subtitle = DateUtil.shared.fullDateString(from: event.startTime)
                    } else {
                        annotation.subtitle = DateUtil.shared.shortTimeString(from: event.startTime)
                    }

                    clusterManager.add(annotation)

                    var zoomRect = MKMapRectNull
                    for annotation in clusterManager.annotations {
                        let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                        if MKMapRectIsNull(zoomRect) {
                            zoomRect = pointRect
                        } else {
                            zoomRect = MKMapRectUnion(zoomRect, pointRect)
                        }
                    }

                    zoomRect = MKMapRectMake(zoomRect.origin.x - zoomRect.size.width * 0.1 , zoomRect.origin.y - zoomRect.size.height * 0.1, zoomRect.size.width * 1.2, zoomRect.size.height * 1.2)
                    clusterManager.reload(map, visibleMapRect: zoomRect)
                    map.setVisibleMapRect(zoomRect, animated: true)
                }
            }
        }
    }
}

class BorderedClusterAnnotationView: ClusterAnnotationView {
    var borderColor: UIColor?

    convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, type: ClusterAnnotationType, borderColor: UIColor) {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier, type: type)
        self.borderColor = borderColor
    }

    override func configure() {
        super.configure()
        switch type {
        case .image:
            break
        case .color:
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = 2
        }
    }
}

extension TimelineViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            view?.canShowCallout = false

            if view == nil {
                if let annotation = annotation.annotations.first as? Annotation, let type = annotation.type {
                    view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, type: type, borderColor: .white)
                } else {
                    view = ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, type: .color(UIColor(red:0.90, green:0.29, blue:0.24, alpha:1.0), radius: 25))
                }
            } else {
                view?.annotation = annotation
            }
            view?.canShowCallout = false
            return view
        } else if annotation.isEqual(mapView.userLocation) {
            return nil
        } else {
             let eventAnnotation = annotation as! EventAnnotation
            let annotationEvent = eventAnnotation.event!

            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.pinTintColor = UIColor(red:0.90, green:0.29, blue:0.24, alpha:1.0)
            } else {
                view?.annotation = annotation
            }

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.backgroundColor = UIColor.clear
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill

            imageView.image = nil

            let cache = SimpleCache.shared

            if let image = cache.image(key:annotationEvent.imageObjectId) {
                imageView.image = image
            }

            //We don't have imageFile in the cache; let's retreive it from the server. Event photo is a PFFile in this state
            if !annotationEvent.imageObjectId.isEmpty {
                let imageObjectId = annotationEvent.imageObjectId
                let query = PFQuery(className: "EventImage")
                query.whereKey("objectId", equalTo: imageObjectId)
                query.getFirstObjectInBackground(block: { (object, error) in
                    guard error == nil else {
                        print ("Error retrieving image data from Parse")
                        return
                    }

                    guard let object = object else { return }
                    guard let imageFile = object["image"] as? PFFile else { return }

                    imageFile.getDataInBackground({ (data, error) in
                        guard error == nil else {
                            print ("Error retrieving image data from Parse")
                            return
                        }
                        guard let imageData = data else { return }
                        guard let image = UIImage(data: imageData) else { return }

                        cache.setImage(image, key: annotationEvent.imageObjectId)
                        imageView.image = image
                    })
                })
            }

            view?.leftCalloutAccessoryView = imageView

            let detailButton = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = detailButton

            view?.canShowCallout = true
            return view
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? ClusterAnnotation {
            mapView.removeAnnotations(mapView.annotations)

            var zoomRect = MKMapRectNull
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = pointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect)
                }
            }

            zoomRect = MKMapRectMake(zoomRect.origin.x - zoomRect.size.width * 0.1 , zoomRect.origin.y - zoomRect.size.height * 0.1, zoomRect.size.width * 1.2, zoomRect.size.height * 1.2)

            clusterManager.reload(mapView, visibleMapRect: zoomRect)
            mapView.setVisibleMapRect(zoomRect, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let eventAnnotation = view.annotation as! EventAnnotation
        let annotationEvent = eventAnnotation.event!

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.event = annotationEvent
        detailViewController.currentForecast = self.currentForecast
        detailViewController.lastKnownUserLocation = self.lastKnownUserLocation

        if let imageView = view.leftCalloutAccessoryView as? UIImageView {
            detailViewController.image = imageView.image
        }

        detailViewController.currentTab = TabBarItems(rawValue: segmentedControl.selectedIndex)!
        detailViewController.lastKnownUserLocation = self.lastKnownUserLocation

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

//MARK: Location Manager Delegate Methods
extension TimelineViewController : CLLocationManagerDelegate {
    //This method gets called when the user responds to the permission dialog. If the user choose Allow, the status becomes CLAuthorizationStatus.AuthorizedWhenInUse.

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation() //turns out requestLocation doesn't fire right away. Changing to startupdatingLocation
        } else if status == .denied {
            let alertController = UIAlertController (title: "Bummer!", message: "Can't show nearby events. You can turn on location services in the Settings page.", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    //This gets called when location information comes back. You get an array of locations, but you’re only interested in the first item. You don’t do anything with it yet, but eventually you will zoom to this location.
    //In our case, below gets called when user taps on "Nearby"
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let lastLocation = locations.last else { return }

        UserDefaults.standard.set(["lat": lastLocation.coordinate.latitude, "lon": lastLocation.coordinate.longitude], forKey: "lastLocation")
        lastKnownUserLocation = lastLocation //this is used for recording user data at Parse

        if userLocationFound == false {
            self.userLocationFound = true

            //if "Nearby" is not selected in the filter list, don't do any updates
            let selectedCells = filtersCollectionView.visibleCells.filter{ $0.isSelected == true }
            if selectedCells.count >= 1 {
                    let cell = selectedCells.first as! FilterCollectionViewCell
                    guard cell.getFilterLabel() == "📍 Nearby" else { return }
            }

            let userGeoPoint = PFGeoPoint(latitude:lastLocation.coordinate.latitude, longitude:lastLocation.coordinate.longitude)

            var e = [Event]()
            let selectedIndex = self.segmentedControl.selectedIndex
            switch selectedIndex {
            case 0:
                e = self.today
            case 1:
                e = self.tomorrow
            case 2:
                e = self.later
            default:
                e = self.today
            }

            var nearbyEvents = [Event]()
            nearbyEvents = e.filter { userGeoPoint.distanceInMiles(to: $0.geoLocation ) < 5 }

            if nearbyEvents.count > 1 {
                self.events = nearbyEvents
            } else {
                let alert = UIAlertController(title: "No Events Nearby", message: "Can't find events within a 5 mile radius. Loading all events.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.events = e
            }
        }

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
        var e = [Event]()
        let selectedIndex = self.segmentedControl.selectedIndex
        switch selectedIndex {
        case 0:
            e = self.today
        case 1:
            e = self.tomorrow
        case 2:
            e = self.later
        default:
            e = self.today
        }

        self.events = e
        let alert = UIAlertController(title: "Uh-Oh", message: "Something went wrong. Loading all events", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
}



