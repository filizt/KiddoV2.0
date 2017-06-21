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

enum TabBarItems : Int {
    case today = 0
    case tomorrow
    case later
    case special
    case none
}

class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAgeInfo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventHours: UILabel!
    @IBOutlet weak var eventCost: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var eventCategory: UIButton!
    @IBOutlet weak var eventFeaturedLabel: UILabel!
    @IBOutlet weak var eventFeaturedStar: UIImageView!
    @IBOutlet weak var eventFullDateLabel: UILabel!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadEventInfo()

        scrollView.delegate = self
        mapView.delegate = self;

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)

        Answers.logCustomEvent(withName: "Detail View", customAttributes:["Event Title": event.title, "Event Category": event.category, "Event Cost": event.freeFlag == true ? "Free" : "Paid"])

        let shareButtonItem = UIBarButtonItem(image: UIImage(named: "shareIcon")!, style: .done, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = shareButtonItem

    }

    override func viewWillAppear(_ animated: Bool) {
//        if event.address != nil {
//            addressStringToGeocode(for: event.address)
//        }

        //check one more time to find an image, if self.image is still nil.

        self.cachedImageViewSize = self.eventImage.frame;

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

    func share() {
        let canonicalIdentifier = "eventId/" + event.id
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: canonicalIdentifier)
        branchUniversalObject.title = event.title
        branchUniversalObject.contentDescription = event.description
        branchUniversalObject.imageUrl = "http://kiddoapp.herokuapp.com/parse/files/1G2h3j45Rtf3s/0fb21cca5841db0816d3fbc8b598ece2_file.jpeg"

        let query = PFQuery(className: "EventImage")
        if let imageObject:PFObject = try? query.getObjectWithId(event.imageObjectId) {
            guard let imageFile = imageObject["image"] as? PFFile else { return }
            branchUniversalObject.imageUrl = imageFile.url
        }

        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.addControlParam("eventId", withValue: event.id)
        linkProperties.feature = "share"

        if let shareUrl = branchUniversalObject.getShortUrl(with: linkProperties) {
            Answers.logCustomEvent(withName: "Event Shared", customAttributes:["Event Title": event.title, "Event Category": event.category, "Event Cost": event.freeFlag == true ? "Free" : "Paid"])

            let shareString =  event.title + " " + shareUrl
            var activityItems : [Any] = [shareString]

            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.airDrop, .print, .assignToContact, .postToFlickr, .postToVimeo]
            self.present(activityViewController, animated: true, completion: nil)

        }
    }

    @IBAction func sendFeedbackPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["feedback@thekiddoapp.com"])
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
        self.title = event.title
        if let image = self.image {
            self.eventImage.image = self.image
        } else {
            self.eventImage.image = UIImage(named: "image_placeholder")
        }
        self.eventDescription.text = event.description
        self.eventAgeInfo.text = "AGES: \(event.ages)"
        self.eventCost.text = event.freeFlag == true ? "COST: Free" : "COST: \(event.price)"
        self.eventHours.text = event.allDayFlag == true ? "LOCATION HOURS: \(event.locationHours)" : "HOURS: \(event.startTime) - \(event.endTime)"

        if event.originalEventURL != nil {
            self.moreInfoButton.setTitle("VISIT EVENT WEBSITE", for: .normal)
        } else {
            self.moreInfoButton.setTitle("", for: .normal)
            self.moreInfoButton.isUserInteractionEnabled = false
        }

        self.eventFeaturedLabel.isHidden = !event.featuredFlag
        self.eventFeaturedStar.isHidden = !event.featuredFlag

        self.eventCategory.isHidden = event.category == "Other" ? true : false
        self.eventCategory.setTitle(event.category, for: .normal)
        self.eventCategory.layer.cornerRadius = 8
        self.eventCategory.layer.masksToBounds = true
        let formatedString = event.category.uppercased()
        self.eventCategory?.setTitle(formatedString, for: .normal)

        if let geoLocation = event.geoLocation {
            self.locationCoordinates = geoLocation.location()
        }

        switch currentTab {
        case .today:
             let eventDate = DateUtil.shared.fullDateStringWithDateStyle(from: DateUtil.shared.todayDate()!)
             self.eventFullDateLabel.text = event.allDayFlag == true ? eventDate : eventDate + " at " + event.startTime
        case .tomorrow:
            let eventDate = DateUtil.shared.fullDateStringWithDateStyle(from: DateUtil.shared.tomorrow()!)
            self.eventFullDateLabel.text = event.allDayFlag == true ? eventDate : eventDate + " at " + event.startTime
        case .later:
            let eventDate = DateUtil.shared.fullDateStringWithDateStyle(from: event.dates.first!)
            self.eventFullDateLabel.text = event.allDayFlag == true ? eventDate : eventDate + " at " + event.startTime
            self.eventFeaturedLabel.isHidden = true
            self.eventFeaturedStar.isHidden = true
        default:
            self.eventFullDateLabel.text = event.location

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

        guard locationCoordinates != nil else { return }

        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]

        let placemark = MKPlacemark(coordinate: locationCoordinates!, addressDictionary: nil)
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
            let safariVC = SFSafariViewController(url:URL(string: url)!)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
}

extension PFGeoPoint {

    func location() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
