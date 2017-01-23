//
//  EventEntryViewController.swift
//  Kiddo
//
//  Created by Filiz Kurban on 12/16/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

class EventEntryViewController: UIViewController {

    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventTime: UITextField!
    @IBOutlet weak var eventPrice: UITextField!
    @IBOutlet weak var eventAddress: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventPicURL: UITextField!

    private let testData = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        //populateTestData()
        saveTestData()
    }


    @IBAction func saveEntry(_ sender: AnyObject) {
        var eventObject: PFObject = PFObject(className: "EventObject")

        eventObject["title"] = self.eventTitle.text
        eventObject["date"] = self.eventDate.text //might need to do validation here
        eventObject["time"] = self.eventTime.text
        eventObject["allDay"] = self.eventTime.isEnabled ? false : true
        eventObject["free"] = self.eventPrice.isEnabled ? false: true
        eventObject["price"] = self.eventPrice.text //might need to do validation here
        eventObject["address"] = self.eventAddress.text
        eventObject["description"] = self.eventDescription.text


        if let imageData = getImageData() {
            let imagePFFile = PFFile(data: imageData)
            imagePFFile?.saveInBackground(block: { (success, error) in
                eventObject["photo"] = imagePFFile
                 eventObject.saveInBackground()
            })
        }
        navigationController?.popViewController(animated: true)
    }

    func populateTestData() {

        var data = [String: String]()
        data["title"] = "Kitty Literature"

        testData.set(data, forKey: "testData1")

        var data1 = testData.dictionary(forKey: "testData1")

    }

    func saveTestData() {

        let eventObject: PFObject = PFObject(className: "EventObject")

        eventObject["title"] = "Toddler Storytime"
        
        if let date = DateUtil.shared.createDate(from: "18-02-2017 03:30") {
            eventObject["startDate"] = date
        }

        if let date = DateUtil.shared.createDate(from: "18-02-2017 05:30") {
            eventObject["endDate"] = date
        }

        eventObject["allDay"] = false
        eventObject["free"] = true
        eventObject["price"] = ""
        eventObject["location"] = "Sammamish Library"
        eventObject["address"] = "825 228th Ave SE Sammamish, WA 98075"
        eventObject["description"] = "Enjoy interactive short stories, songs and creative movement- just right for busy kiddos, followed by bubbles and hand stamps. Please arrive on time, due to space limits. Please choose only one Story Time to attend weekly."
        eventObject["imageURL"] = "http://www.seattlehumane.org/sites/default/files/styles/content_image_breakpoints_theme_seattle_humane_society_wide_1x/public/Untitled-1_4.jpg"

        if let imageData = getImageData() {
            let imagePFFile = PFFile(data: imageData)
            imagePFFile?.saveInBackground(block: { (success, error) in
                eventObject["photo"] = imagePFFile
                eventObject.saveInBackground()
            })
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func allDayEventSwitchTapped(_ sender: UISwitch) {
        self.eventTime.isEnabled = sender.isOn ? false : true
        self.eventTime.text = self.eventTime.isEnabled ? self.eventTime.text : ""
    }


    @IBAction func freeEventSwitchTapped(_ sender: UISwitch) {
        self.eventPrice.isEnabled = sender.isOn ? false : true
        self.eventPrice.text = self.eventPrice.isEnabled ? self.eventPrice.text : ""
    }
    
    func getImageData() -> Data? {
        let url = URL(string:"http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        let data = try? Data(contentsOf:url!)
        return data;
    }
}
