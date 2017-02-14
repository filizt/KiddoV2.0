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

class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAgeInfo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventHours: UILabel!
    @IBOutlet weak var eventCost: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!

    var event: Event!
    var image: UIImage!
    var cachedImageViewSize: CGRect!
    var region: MKCoordinateRegion!
    var locationCoordinates: CLLocationCoordinate2D? {
        didSet {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.locationCoordinates!
            region = MKCoordinateRegionMakeWithDistance(locationCoordinates!, 500, 500);
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadEventInfo()

        scrollView.delegate = self
        mapView.delegate = self;

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        addressStringToGeocode(for: event.address)
        self.cachedImageViewSize = self.eventImage.frame;
    }

    private func loadEventInfo() {
        self.title = event.title
        self.eventImage.image = self.image
        self.eventDescription.text = event.description
        self.eventAgeInfo.text = "AGES: \(event.ages)"
        self.eventCost.text = event.freeFlag == true ? "COST: Free" : "COST: \(event.price)"
        self.eventHours.text = event.allDayFlag == true ? "LOCATION HOURS: \(event.locationHours)" : "HOURS: \(event.startTime) - \(event.endTime)"

        if event.originalEventURL != nil {
            self.moreInfoButton.setTitle("Visit Event Website", for: .normal)
        } else {
            self.moreInfoButton.setTitle("", for: .normal)
            self.moreInfoButton.isUserInteractionEnabled = false
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

    func addressStringToGeocode(for addressString: String) {
        let address = addressString
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            guard error == nil else { return }

            if let placemark = placemarks?.first {
                if let location = placemark.location {
                    self.locationCoordinates = location.coordinate
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
