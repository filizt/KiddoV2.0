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
import UserNotifications
import CoreLocation
import MapKit
import Crashlytics
import MessageUI
import Branch
import Contacts
import ForecastIO
import EventKit
import Mixpanel

enum TabBarItems : Int {
    case today = 0
    case tomorrow
    case later
    case special
    case none
}

class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var eventCategory: UIButton!
    @IBOutlet weak var eventSessionsCollectionView: UICollectionView!
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventFullDateLabel: UILabel!
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var eventAgeInfo: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var buyTicketsButton: UIButton!
    
    @IBOutlet weak var buyTicketsButtonPadding: UIView!
    var event: Event!
    var image: UIImage? = nil
    var currentTab: TabBarItems = TabBarItems.today
    var cachedImageViewSize: CGRect!
    var region: MKCoordinateRegion!
    var locationCoordinates: CLLocationCoordinate2D? {
        didSet {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.locationCoordinates!
            annotation.title = event.location
            annotation.subtitle = "Tap to get directions"
            region = MKCoordinateRegionMakeWithDistance(locationCoordinates!, 500, 500);
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    var lastKnownUserLocation : CLLocation?
    var currentForecast: DataPoint?
    var selectedEventSession = 0 {//0 is default
        didSet {
            self.eventSessionsCollectionView.reloadData()
        }
    }
    //var eventDateForCalendar: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        //call a sperate function here for deep link
        //        default: //if we hit here it means we're coming from following a deeplink
        //            if let date = Event.pushedEventForDateTime {
        //                self.eventFullDateLabel.text = date
        //            } else {
        //                let eventDate = DateUtil.shared.fullDateStringWithDateTimeStyle(from: event.dates.first!)
        //                self.eventFullDateLabel.text = eventDate
        //            }

        //self.eventHours.text = DateUtil.shared.shortTime(from:event.startTime) + " - " + DateUtil.shared.shortTime(from:event.endTime)

        self.loadEventInfo()

        scrollView.delegate = self
        mapView.delegate = self;

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)

        Answers.logCustomEvent(withName: "Detail View", customAttributes:["Event Title": event.title, "Event Category": event.category, "Event Cost": event.freeFlag == true ? "Free" : "Paid"])

        let shareButtonItem = UIBarButtonItem(image: UIImage(named: "shareIcon")!, style: .done, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = shareButtonItem

        self.eventSessionsCollectionView.delegate = self
        self.eventSessionsCollectionView.dataSource = self

        buyTicketsButton.layer.cornerRadius = 5
        buyTicketsButton.clipsToBounds = true

        recordDetailView()

        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.needAuthForPushNotifications()
                }
            }
        })
    }


    override func viewWillAppear(_ animated: Bool) {
//        if event.address != nil {
//            addressStringToGeocode(for: event.address)
//        }

        if let image = self.eventImage.image {
            if image.size.width * 0.60 <= image.size.height {
                if let croppedImage = cropImage(image: image) {
                    self.eventImage.image = croppedImage
                }
            }
            self.cachedImageViewSize = self.eventImage.frame;
        }

        //check one more time to find an image, if self.image is still nil.
        guard self.image == nil else {
            return
        }

        if let image = SimpleCache.shared.image(key: (event.imageObjectId)) {
            self.image = image
        } else {
            let query = PFQuery(className: "EventImage")
            query.getObjectInBackground(withId: event.imageObjectId) {(object, error) -> Void in
                    guard let imageFile = object?["image"] as? PFFile else { return }

                    imageFile.getDataInBackground({ (data, error) in
                    guard error == nil else {
                        print ("Error retrieving image data from Parse")
                        return
                    }
                    guard let imageData = data else { return }
                    guard let image = UIImage(data: imageData) else { return }

                    self.image = image
                    self.eventImage.image = self.image
                })
            }
        }
    }
    
    private func cropImage(image: UIImage) -> UIImage?  {

        let cgwidth: CGFloat = image.size.width
        let cgheight: CGFloat = image.size.width * 0.60
        let rect: CGRect = CGRect(x:0, y:0, width: cgwidth, height: cgheight)


        guard let cgImage = image.cgImage else { return nil }
        guard let croppedImageRect = cgImage.cropping(to: rect) else { return nil }

        let image = UIImage(cgImage: croppedImageRect, scale: image.scale, orientation: image.imageOrientation)

        return image
    }

    private func recordDetailView() {
        recordUserInfo() // geoplookup completion handler calls recordUserAction()
    }

    func recordUserInfo() {
        var dict = [String:MixpanelType]()

        if let currentUser = PFUser.current() {
            if let objId = currentUser.objectId {
                dict["ParseUserId"] = objId
            }
        }

        if let location = lastKnownUserLocation {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {[weak weakSelf = self] (placemarks, error) -> Void in
                if error == nil {
                    if let city = placemarks?.first?.locality,
                        let postCode = placemarks?.first?.postalAddress?.postalCode,
                        let streetAddress = placemarks?.first?.postalAddress?.street {
                        dict["userLocation"] = city
                        dict["postCode"] = postCode

                        Mixpanel.mainInstance().registerSuperProperties(dict)

                        weakSelf?.recordUserAction()
                    }
                }
            })
        } else {
            dict["userLocation"] = ""
            dict["postCode"] = ""
            Mixpanel.mainInstance().registerSuperProperties(dict)
            self.recordUserAction()
        }

    }

    func recordUserAction() {
        var currentWeather = ""
        var currentTemperature = 0
        if self.currentForecast?.summary != nil && self.currentForecast?.temperature != nil {
            currentWeather = (self.currentForecast?.summary)!
            currentTemperature = Int(abs((self.currentForecast?.temperature)!))
        }

        Mixpanel.mainInstance().track(event: "EventDetailView", properties: ["event Id" : self.event.id, "eventCategory" : self.event.category, "eventTitle" : self.event.title, "freeEvent" : self.event.freeFlag, "eventLocation": self.event.location, "currentWeather": currentWeather, "currentTemperature" : currentTemperature])

        depricatedRecordUserAction()

    }

    private func depricatedRecordUserAction() {
        let userInfo: PFObject = PFObject(className: "UserDetailViewHistory")
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = PFUser.current()?.objectId
        }

        userInfo["eventId"] = self.event.id
        userInfo["eventCategory"] = self.event.category
        userInfo["eventTitle"] = self.event.title
        userInfo["eventCost"] = self.event.freeFlag == true ? "Free" : "Paid"
        userInfo["eventDate"] = self.eventFullDateLabel.text

        if self.currentForecast?.temperature != nil && self.currentForecast?.summary != nil {
            userInfo["currentTemprature"] = Int((self.currentForecast?.temperature)!)
            userInfo["currentWeather"] = self.currentForecast?.summary
        }


        if let location = lastKnownUserLocation {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error == nil {
                    if let city = placemarks?.first?.locality,
                        let postCode = placemarks?.first?.postalAddress?.postalCode,
                        let streetAddress = placemarks?.first?.postalAddress?.street {
                        userInfo["userLocation"] = city
                        userInfo["postCode"] = postCode
                        //userInfo["streetAddress"] = streetAddress
                        //userInfo["userGeoLocation"] = [placemarks?.first?.location?.coordinate.latitude, placemarks?.first?.location?.coordinate.longitude]
                    }
                }
                //either there is an error or not let's save what we have.
                userInfo.saveInBackground()
            })
        } else {
            userInfo.saveInBackground()
        }
    }

    func share() {
        //fetch user information for recording the share
        let userInfo: PFObject = PFObject(className: "UserShareHistory")
        if let currentParseUserObjectId = PFUser.current()?.objectId {
            userInfo["parseUser"] = PFUser.current()
            userInfo["parseUserId"] = currentParseUserObjectId
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
        } else if let email = UserDefaults.standard.object(forKey: "email") as? String {  //where user didn't log in with FB but used their email to sign up
            if let vendorIdentifier = UIDevice.current.identifierForVendor {
                userInfo["UUID"] = vendorIdentifier.uuidString
            }
            userInfo["email"] = email
        }

        //share prep
        let canonicalIdentifier = "eventId/" + event.id
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: canonicalIdentifier)
        branchUniversalObject.title = event.title
        branchUniversalObject.contentDescription = event.description
        if let eventDateTime = self.eventFullDateLabel.text {
            branchUniversalObject.addMetadataKey("forDateTime", value: eventDateTime)
        }
        branchUniversalObject.imageUrl = "http://kiddoapp.herokuapp.com/parse/files/1G2h3j45Rtf3s/f99a2119a2769ac8ea12c269f0bbda96_file.jpeg"

        let query = PFQuery(className: "EventImage")
        if let imageObject:PFObject = try? query.getObjectWithId(event.imageObjectId) {
            guard let imageFile = imageObject["image"] as? PFFile else { return }
            branchUniversalObject.imageUrl = imageFile.url
        }

        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.addControlParam("eventId", withValue: event.id)
        linkProperties.feature = "share"

        if let shareUrl = branchUniversalObject.getShortUrl(with: linkProperties) {
            let shareString =  event.title + " " + shareUrl
            let activityItems : [Any] = [shareString]

            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.airDrop, .print, .assignToContact, .postToFlickr, .postToVimeo]
            activityViewController.completionWithItemsHandler = {(activity, success, items, err) in
                // Return if cancelled
                let userParseId = userInfo["parseUserId"] as? String
                    if (!success) {
                        userInfo["shareURL"] = shareUrl
                        userInfo["eventId"] = self.event.id
                        userInfo["eventCategory"] = self.event.category
                        userInfo["eventTitle"] = self.event.title
                        userInfo["eventCost"] = self.event.freeFlag == true ? "Free" : "Paid"
                        userInfo["shareStatus"] = "FAILED"
                        userInfo["eventDate"] = self.eventFullDateLabel.text
                        userInfo.saveInBackground()
                        return
                    } else {
                        userInfo["shareURL"] = shareUrl
                        userInfo["eventId"] = self.event.id
                        userInfo["eventCategory"] = self.event.category
                        userInfo["eventTitle"] = self.event.title
                        userInfo["eventCost"] = self.event.freeFlag == true ? "Free" : "Paid"
                        userInfo["shareType"] = activity?.rawValue
                        userInfo["shareStatus"] = "Success"
                        userInfo["eventDate"] = self.eventFullDateLabel.text
                        userInfo.saveInBackground()
                    }
                Answers.logCustomEvent(withName: "Event Shared", customAttributes:["Event Title": self.event.title, "Event Category": self.event.category, "Event Cost": self.event.freeFlag == true ? "Free" : "Paid"])
                Mixpanel.mainInstance().track(event: "Event Shared", properties: ["Event Id" : self.event.id, "Event Category" : self.event.category, "Event Title" : self.event.title, "freeEvent" : self.event.freeFlag, "Event Location" : self.event.location])
            }

            self.present(activityViewController, animated: true) {
                print ("In the completion handler")
            }
        }
    }

    //Add Event to Calendar

    @IBAction func addToCalendarButtonPressed(_ sender: Any) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        switch (status) {
                    case EKAuthorizationStatus.notDetermined:
                            // This happens on first-run
                                EKEventStore().requestAccess(to: .event, completion: {
                                    (accessGranted: Bool, error: Error?) in
                                    if accessGranted == true {
                                        DispatchQueue.main.async(execute: {
                                            print("access granted")
                                            self.addEventToCalendar()
                                        })
                                    } else {
                                        DispatchQueue.main.async(execute: {
                                            print("access denied")
                                        })
                                    }
                                })
                    case EKAuthorizationStatus.authorized:
                            // Things are in line with being able to show the calendars in the table view
                                print("authorized")
                                self.addEventToCalendar()
                    case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                           // We need to help them give us permission
                        askAuthForCalendarAccess()
                        print("denied")
                    }

    }

    private func addEventToCalendar() {
        let eventStore = EKEventStore();
        let newEvent = EKEvent(eventStore: eventStore)
        //https://stackoverflow.com/questions/48175452/defaultcalendarfornewevents-is-defined-as-optional-however-cant-use-optional-bi/48196230#48196230
        //Hence the nil check.
        if eventStore.defaultCalendarForNewEvents != nil {
            newEvent.calendar = eventStore.defaultCalendarForNewEvents
            newEvent.title = "Kiddo: " + self.event.title
            newEvent.startDate = event.eventInstances[selectedEventSession].0 //start date
            newEvent.endDate = event.eventInstances[selectedEventSession].1 //end date
            newEvent.location = event.location + " " + event.address

            Mixpanel.mainInstance().track(event: "AddToCalendarPressed", properties: ["Event Id" : self.event.id, "Event Category" : self.event.category, "Event Title" : self.event.title, "Free Event" : self.event.freeFlag, "Event Location" : self.event.location])

       // Save the calendar using the Event Store instance
        if let saved = try? eventStore.save(newEvent, span: .thisEvent, commit: true) {
                let msg = "\"" + self.event.title + "\" " + "is added to the default calendar"
                let alert = UIAlertController(title: "Added!", message: msg, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style:.default, handler: nil)
                    alert.addAction(OKAction)

                    self.present(alert, animated: true, completion: nil)
                   // self.dismiss(animated: true, completion: nil)
            } else { //need to fix this part a little bit to get the errors, etc.
                let alert = UIAlertController(title: "Event could not be saved", message: "error.localizedDescription", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style:.default, handler: nil)
                    alert.addAction(OKAction)

                    self.present(alert, animated: true, completion: nil)

            }

        }

        //self.performSegue(withIdentifier: "showDetailView", sender: nil)
    }

    func askAuthForCalendarAccess() {
        let alertController = UIAlertController (title: "Calendar Access", message: "Looks like we can't access your calendar. You can enable this in the Settings page. ", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil )
        alertController.addAction(cancelAction)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            //Don't need a completion handler here due to : https://stackoverflow.com/questions/26115265/app-crashes-on-enabling-camera-access-from-settings-ios-8
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil )
            }
        }
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buyTicketsButtonPressed(_ sender: UIButton) {

        if !event.ticketsURL.isEmpty {
            guard let urlString = URL(string : event.ticketsURL) else { return }

            appState = AppStateTracker.State.appWillEnterForegroundFromLocallySpawnedProcess(AppStateTracker.ProcessName.Browser)

            UIApplication.shared.open(urlString, options: [:], completionHandler: { (status) in
                //record analytics here
                Mixpanel.mainInstance().track(event: "Buy Tickets Pressed", properties: ["event Id" : self.event.id, "Event Title": self.event.title, "Event Location" : self.event.location, "freeEvent" : self.event.freeFlag, "Event Ages": self.event.ages ])
            })
        } 
    }
    
    @IBAction func sendFeedbackPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@kiddolocal.com"])
            mail.setSubject("Kiddo User Feedback")

            var messageBody = "Let us know what you think about this event or Kiddo in general. We're listening."
            messageBody += "<br/><br/><br/><br> <br> --------------------------"
            messageBody += "<br/> Event Id: " + event.id
            messageBody += "<br/> Event Title: " + event.title
            messageBody += "<br/> Event Date: " + (self.eventFullDateLabel.text ?? "")
            messageBody += "<br/> Current Tab: " + currentTab.rawValue.description
            messageBody += "<br/> User Id: " + (PFUser.current()?.objectId ?? "Anonymous User")
            messageBody += "<br/> IOS version: " + UIDevice.current.systemVersion
            messageBody += "<br/> Device model: " + UIDevice.current.localizedModel
            messageBody += "<br/> App version: " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
            messageBody += "<br/> --------------------------<br/><br/>"
            mail.setMessageBody(messageBody, isHTML: true)

            self.present(mail, animated: true, completion: nil)
        }
        else {
            self.showSendMailErrorAlert()
        }
    }

    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Email Error", message: "Your device cannot send emails.  Please check email configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(sendMailErrorAlert, animated:true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    private func loadEventInfo() {
        self.eventCategory.isHidden = false
        let formatedString = event.category.uppercased()
        self.eventCategory?.setTitle(formatedString, for: .normal)
        self.eventCategory.layer.cornerRadius = 8
        self.eventCategory.layer.masksToBounds = true
        self.buyTicketsButton.isHidden = true
        self.buyTicketsButtonPadding.isHidden = true

        if !event.ticketsURL.isEmpty {
            self.buyTicketsButton.isHidden = false
            self.buyTicketsButtonPadding.isHidden = false
        }

        if self.image != nil {
            self.eventImage.image = self.image
        } else {
            self.eventImage.image = UIImage(named: "image_placeholder")
        }

        self.eventTitle.text = event.title

        self.eventFullDateLabel.text = DateUtil.shared.fullDateString(from: event.startTime)

        self.eventAgeInfo.text = event.ages

//        if !event.discountedTicketsURL.isEmpty {
//            let attributeString =  NSMutableAttributedString(string: self.event.price)
//            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//            self.eventPrice.attributedText = attributeString
//        } else {
            self.eventPrice.text = event.freeFlag == true ? "Free" : event.price

       // }

        self.eventLocation.text = event.address

        self.eventDescription.text = event.description

        if event.originalEventURL != nil {
            self.moreInfoButton.setTitle("VISIT EVENT WEBSITE", for: .normal)
        } else {
            self.moreInfoButton.setTitle("", for: .normal)
            self.moreInfoButton.isUserInteractionEnabled = false
        }


        if let geoLocation = event.geoLocation {
            self.locationCoordinates = geoLocation.location()
        }


    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let y = -scrollView.contentOffset.y;

        if (y > 0) {
            self.eventImage.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.cachedImageViewSize.size.width+y, height: self.cachedImageViewSize.size.height+y)
            self.eventImage.center = CGPoint(x:self.view.center.x, y:self.eventImage.center.y);
        } 
    }

    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {

        Answers.logCustomEvent(withName: "Directions Requested", customAttributes:["Event Occurs": currentTab])
        Mixpanel.mainInstance().track(event: "Directions Requested", properties: ["Event Id" : self.event.id, "Event Category" : self.event.category, "Event Title" : self.event.title, "Free Event" : self.event.freeFlag, "Event Location" : self.event.location])

        guard locationCoordinates != nil else { return }

        appState = AppStateTracker.State.appWillEnterForegroundFromLocallySpawnedProcess(AppStateTracker.ProcessName.Maps)

        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]

        let addressDictionary = [CNPostalAddressStreetKey: self.event.address]
        let placemark = MKPlacemark(coordinate: locationCoordinates!, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = self.event.location
        mapItem.openInMaps(launchOptions: options)
    }

    //Below function is depricated. We store PFGeoPoint object with EventObject at Parse
    func addressStringToGeocode(for addressString: String) {
        let address = addressString
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address, completionHandler: {[weak weakSelf = self] (placemarks, error) -> Void in
            guard error == nil else { return }

            if let placemark = placemarks?.first {
                if let location = placemark.location {
                    weakSelf?.locationCoordinates = location.coordinate
                }
            }
        })
    }

    @IBAction func moreInformationButton(_ sender: AnyObject) {
        self.presentSafariViewController(url: event.originalEventURL!)
    }

    func presentSafariViewController(url: String) {
        if !url.isEmpty {
            let userInfo: PFObject = PFObject(className: "UserWebsiteVisitHistory")
            if let currentParseUserObjectId = PFUser.current()?.objectId {
                userInfo["parseUser"] = PFUser.current()
                userInfo["parseUserId"] = PFUser.current()?.objectId
            } else if let email = UserDefaults.standard.object(forKey: "email") as? String  { //where user didn't log in with FB but used their email to sign up
                if let vendorIdentifier = UIDevice.current.identifierForVendor {
                    userInfo["UUID"] = vendorIdentifier.uuidString
                }
                userInfo["email"] = email
            }

            userInfo["eventId"] = self.event.id
            userInfo["eventCategory"] = self.event.category
            userInfo["eventTitle"] = self.event.title
            userInfo["eventCost"] = self.event.freeFlag == true ? "Free" : "Paid"
            userInfo.saveInBackground()

            let safariVC = SFSafariViewController(url:URL(string: url)!)

            self.present(safariVC, animated: true, completion: nil)
        }
    }

    // MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event.eventInstances.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventSessionsCell", for: indexPath) as! EventSessionsCollectionViewCell
        let eventItem = event.eventInstances[indexPath.row]
        cell.timeLabel.text = DateUtil.shared.shortTimeString(from: eventItem.0) + " - " + DateUtil.shared.shortTimeString(from: eventItem.1)
        cell.timeLabel.backgroundColor = UIColor.white

        cell.timeLabel.layer.cornerRadius = 5
        cell.timeLabel.layer.borderWidth = 0.5
        cell.timeLabel.layer.borderColor = UIColor.lightGray.cgColor

        //This will be on later.
        if indexPath.row == selectedEventSession {
            //default selected
            cell.timeLabel.layer.borderColor = UIColor(red:0.39, green:0.00, blue:0.00, alpha:1.0).cgColor
            cell.timeLabel.layer.borderWidth = 0.7
            cell.isSelected = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //changeActive Selection here as well
        self.selectedEventSession = (collectionView.indexPathsForSelectedItems?.first?.row)!

    }



    //MARK: Local Notifications

    private func needAuthForPushNotifications() {

        if let lastPushNotificationRequest = UserDefaults.standard.object(forKey: "lastPushNotificationRequest") as? Date {

            if Int(lastPushNotificationRequest.timeIntervalSinceNow * -1) >=  (60*60*24*15) {
                //it's been 15 days or more since we last asked the user to give authorization for push notifications. Let's try that again.
                _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.askForPushAuth), userInfo: nil, repeats: false)
            } else {
                return
            }
        } else { //firsttime
            _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.askForPushAuth), userInfo: nil, repeats: false)
        }
    }
//Enable push notifications to get alerts for recently discounted theatre shows and trending events around. You can change this setting any time in the Settings page.
   func askForPushAuth() {
        let notificationAlert = UIAlertController(title: "Notifications", message: "Enable notifications to be the first to know about recently discounted theatre shows and trending events by receiving alerts directly to your phone. \n\n You can change this any time in the Settings page.", preferredStyle: UIAlertControllerStyle.alert)

        notificationAlert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { (_) -> Void in
            UserDefaults.standard.set(Date(), forKey: "lastPushNotificationRequest")
        }))
        notificationAlert.addAction(UIAlertAction(title: "Enable", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                self.requestAuthForNotifications()
            }
        }))

        present(notificationAlert, animated: true, completion: nil )
    }


    func requestAuthForNotifications() {

        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.askAuthForPushNotifications()
                }
            } else if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .sound,.badge]) {(granted, error) in
                    if granted {
                        //schedule notifications.
                        //self.scheduleLocalNotifications()
                        Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Authroized"])
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        Answers.logCustomEvent(withName: "UserNotificationAuth", customAttributes: ["Notifications":"Denied"])
                        UserDefaults.standard.set(Date(), forKey: "lastPushNotificationRequest")
                    }
                }
            } 
        })
    }

    func askAuthForPushNotifications() {
        let alertController = UIAlertController (title: "Notifications", message: "Looks like the notifications are turned off. You can enable this in the Settings page. ", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Not Now", style: .default, handler: { (_) -> Void in
            UserDefaults.standard.set(Date(), forKey: "lastPushNotificationRequest")
        })
        alertController.addAction(cancelAction)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                     appState = AppStateTracker.State.appWillEnterForegroundFromLocallySpawnedProcess(AppStateTracker.ProcessName.Settings)
                })
            }
        }
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }

    //Turns out we can only ask the user once for notification auth. So commenting below code out.
    //    func notificationsAuthNeeded() -> Bool {
    //        if let lastNotificationAuthRequest = UserDefaults.standard.object(forKey: "UserNotificationsDeniedKey") as? Date {
    //            guard ((lastNotificationAuthRequest.timeIntervalSinceNow * -1) >= (60*60*24*3)) else { return false }
    //        }
    //
    //        return true //first time user case
    //    }
//
//    func scheduleLocalNotifications() {
//        //time interval is every 3 days
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*24*2), repeats: true)
//
//        let content = UNMutableNotificationContent()
//        content.title = "Kiddo"
//        content.body = "New events and activities added every day! Come check them out!"
//        content.sound = UNNotificationSound.default()
//
//        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) {(error) in
//            if let error = error {
//                print("Uh oh! We had an error: \(error)")
//            }
//        }
//    }

}

extension PFGeoPoint {

    func location() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

