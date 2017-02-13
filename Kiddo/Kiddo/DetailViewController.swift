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

    var event: Event!
    var image: UIImage!
    var cachedImageViewSize: CGRect!
    var region: MKCoordinateRegion!
    var locationCoordinates = CLLocationCoordinate2D() {
        didSet {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.locationCoordinates
            region = MKCoordinateRegionMakeWithDistance(locationCoordinates, 500, 500);
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.eventAddress.text = event.eventAddress
        // self.eventStartTime.text = event.eventStartTime

        self.eventImage.image = self.image
        self.eventDescription.text = event.description
        self.eventAgeInfo.text = "AGES 0-5"

        navigationController?.navigationBar.topItem?.title = event.title
        scrollView.delegate = self

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.mapView.delegate = self;
        addressStringToGeocode(for: event.address)
        self.cachedImageViewSize = self.eventImage.frame;
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y;

        if (y > 0) {
            self.eventImage.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: self.cachedImageViewSize.size.width+y, height: self.cachedImageViewSize.size.height+y)
            self.eventImage.center = CGPoint(x:self.view.center.x, y:self.eventImage.center.y);
        }
    }

    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]

        let placemark = MKPlacemark(coordinate: locationCoordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = "Home"
        mapItem.openInMaps(launchOptions: options)
    }

    func addressStringToGeocode(for addressString: String) {
        let address = "325 Harvard Ave E. Seattle 98122"
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            guard error == nil else { return }

            if let placemark = placemarks?.first {
                self.locationCoordinates = placemark.location!.coordinate

            }
        })
    }

    @IBAction func moreInformationButton(_ sender: AnyObject) {
        self.presentSafariViewController(url: event.originalEventURL)

    }

    func presentSafariViewController(url: String) {
        let safariVC = SFSafariViewController(url:URL(string: url)!)
        self.present(safariVC, animated: true, completion: nil)
    }


}
