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

    private var testData = [String: [String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteUserDefaultsData()
        // createDateObjects()
        //populateTestData()
        //saveTestData()
        downloadEventImagesFromSource()
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


        self.getImageData(urlString: "http://www.seattlehumane.org/sites/default/files/styles/content_image_breakpoints_theme_seattle_humane_society_wide_1x/public/Untitled-1_4.jpg") { (imageData) in
            if let imageData = imageData {
                let imagePFFile = PFFile(data: imageData)
                imagePFFile?.saveInBackground(block: { (success, error) in
                    eventObject["photo"] = imagePFFile
                    eventObject.saveInBackground()
                })
            }
        }
        navigationController?.popViewController(animated: true)
    }

    func deleteUserDefaultsData() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }

    func populateTestData() {

        var data = [String: Any]()
        data["title"] = "Toddler Time"
        var allEventDates = [Date]()
        var eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        var eventDate2 = DateUtil.shared.createDate(from: "02-02-2017 10:00")
        allEventDates.append(eventDate1!)
        allEventDates.append(eventDate2!)
        data["allEventDates"] = allEventDates
        data["startDate"] = "25-01-2017 09:30"
        data["endDate"] = "03-30-2017 12:00"
        data["allDay"] = false as Bool
        data["free"] = true as Bool
        data["price"] = "" as String
        data["location"] = "Seattle Aquarium" as String
        data["address"] = "1483 Alaskan Way, Seattle, WA 98101"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["imageURL"] = "http://www.seattleaquarium.org/image/private-events/Aquarium-Photos-017.jpg"

        testData["1"] =  data


        data = [String: Any]()
        data["title"] = "Preschool Family Play Lab"
        allEventDates = [Date]()
        eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        eventDate2 = DateUtil.shared.createDate(from: "02-02-2017 10:00")
        allEventDates.append(eventDate1!)
        allEventDates.append(eventDate2!)
        data["allEventDates"] = allEventDates
        data["startDate"] = "25-01-2017 09:30"
        data["endDate"] = "03-30-2017 12:00"
        data["allDay"] = false as Bool
        data["free"] = false as Bool
        data["price"] = "$20, or $15 for Pacific Science Center Members"
        data["location"] = "Pacific Science Center" as String
        data["address"] = "200 2nd Ave N, Seattle, WA 98109"
        data["description"] = "At Preschool Family Play Lab, kids learn about science with their favorite person, you. Play Lab gives you the tools to help you teach your child science. In each 1.5 hour class, you and your child will sing songs, experiment with different materials and learn together about a specific science theme in our designated Early Learning Classroom. Afterwards, explore exhibits with your child. An adult must be present with each child at all times. For more information, call (206) 269-5741. Any adult family members or close friends (i.e. parents, grandparents, godparents, aunts, uncles, nannies, etc.) are welcome to accompany a child"
        data["imageURL"] = "https://www.pacificsciencecenter.org/wp-content/uploads/pacsci-view-16x9-2500x1406-compressed.jpg"

        testData["2"] =  data



        data = [String: Any]()
        data["title"] = "Sensory Friendly Concerts"
        allEventDates = [Date]()
        eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        eventDate2 = DateUtil.shared.createDate(from: "03-02-2017 10:00")
        let eventDate3 = DateUtil.shared.createDate(from: "02-02-2017 10:00")
        allEventDates.append(eventDate1!)
        allEventDates.append(eventDate2!)
        allEventDates.append(eventDate3!)
        data["allEventDates"] = allEventDates
        data["startDate"] = "04-02-2017 10:00"
        data["endDate"] = "04-02-2017 12:00"
        data["allDay"] = false as Bool
        data["free"] = true as Bool
        data["price"] = "" as String
        data["location"] = "Beneroya Hall" as String
        data["address"] = "825 228th Ave SE Sammamish, WA 98075"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["imageURL"] = "http://www.seattlesymphony.org/~/media/images/1617%20eventbanner%20880x399/1617_0204and0205_twocats_880x399.jpg"

        testData["3"] =  data



        data = [String: Any]()
        data["title"] = "Toddler Time"
        allEventDates = [Date]()

        data["allEventDates"] = allEventDates
        data["startDate"] = "25-01-2017 09:30"
        data["endDate"] = "03-30-2017 12:00"
        data["allDay"] = false as Bool
        data["free"] = true as Bool
        data["price"] = ""
        data["location"] = "Seattle Aquarium"
        data["address"] = "825 228th Ave SE Sammamish, WA 98075"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["imageURL"] = "http://weinsteinau.com/wp-content/uploads/2013/11/WPZ_03_West_Entry_Entry.jpg"

        testData["4"] =  data



        data = [String: Any]()
        data["title"] = "Woodland Park Zoo"
        allEventDates = [Date]()
        eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        eventDate2 = DateUtil.shared.createDate(from: "03-02-2017 10:00")
        allEventDates.append(eventDate1!)
        allEventDates.append(eventDate2!)
        data["allEventDates"] = allEventDates
        data["startDate"] = "25-01-2017 09:30"
        data["endDate"] = "03-30-2017 12:00"
        data["allDay"] = false as Bool
        data["free"] = true as Bool
        data["price"] = "" as String
        data["location"] = "Seattle Aquarium" as String
        data["address"] = "825 228th Ave SE Sammamish, WA 98075"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["imageURL"] = "https://img.grouponcdn.com/deal/f5f3c5719806412f8ba2ce68e83d6947/47/v1/c700x420.jpg"

        testData["5"] = data

    }

    func saveTestData() {

            for entry in self.testData {
                if let test = self.testData[entry.key] {
                    let eventObject: PFObject = PFObject(className: "EventObject")
                    eventObject["title"] = test["title"]
                    if let date = DateUtil.shared.createDate(from: test["startDate"] as! String) {
                        eventObject["startDate"] = date
                    }
                    if let date = DateUtil.shared.createDate(from: test["endDate"] as! String) {
                        eventObject["endDate"] = date
                    }

                    eventObject["allDay"] = test["allDay"] as! Bool
                    eventObject["free"] = test ["free"] as! Bool
                    eventObject["price"] =  test["price"] as! String
                    eventObject["location"] = test["location"] as! String
                    eventObject["address"] = test["address"] as! String
                    eventObject["imageURL"] = test["imageURL"] as! String
                    eventObject["allEventDates"] = test["allEventDates"] as! [Date];

                    let alleventdates = test["allEventDates"] as! [Date];

                    //event object has all the date it needs. Save it now. In the completion handler
                    //we can check which dates it needs to have relation with.
                    guard let _ = try? eventObject.save() else { return }

                    for date in alleventdates {
                        //let date = alleventdates[0]
                        let q = PFQuery(className: "EventDate")
                        q.whereKey("eventDate", equalTo: date)
                        if let eventDateObjects = try? q.findObjects() {
                            if eventDateObjects.count == 0 {
                                let dateObject: PFObject = PFObject(className: "EventDate")
                                dateObject["eventDate"] = date
                                let relation = dateObject.relation(forKey: "events")
                                relation.add(eventObject)
                                guard let _ = try? dateObject.save() else { return }
                            } else {
                                let existingDateObject = eventDateObjects[0]
                                let relation = existingDateObject.relation(forKey: "events")
                                relation.add(eventObject)
                                guard let _ = try? existingDateObject.save() else { return }
                            }
                        }
                    }

                }
            }
      //  })

        navigationController?.popViewController(animated: true)
    }

    private func downloadEventImagesFromSource() {
        let query = PFQuery(className: "EventObject")
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                for eventObject in objects {
                    guard let url = eventObject["imageURL"] else { continue }

                    self.getImageData(urlString: url as! String) { (imageData) in
                        if let imageData = imageData {
                            let imagePFFile = PFFile(data: imageData)
                            imagePFFile?.saveInBackground(block: { (success, error) in
                                eventObject["photo"] = imagePFFile
                                eventObject.saveInBackground()
                            })
                        }
                    }
                }
            }
        }
    }

    private func createDateObjects() {
        var allEventDates = [Date]()
        let eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        allEventDates.append(eventDate1!)

        for date in allEventDates {
            let dateObject: PFObject = PFObject(className: "EventDate")
            dateObject["eventDate"] = date

            let result = try? dateObject.save()

        }
    }

    @IBAction func allDayEventSwitchTapped(_ sender: UISwitch) {
        self.eventTime.isEnabled = sender.isOn ? false : true
        self.eventTime.text = self.eventTime.isEnabled ? self.eventTime.text : ""
    }


    @IBAction func freeEventSwitchTapped(_ sender: UISwitch) {
        self.eventPrice.isEnabled = sender.isOn ? false : true
        self.eventPrice.text = self.eventPrice.isEnabled ? self.eventPrice.text : ""
    }

    func getImageData(urlString: String, completion: @escaping (Data?) -> ()) {

        guard let url = URL(string: urlString) else { return completion(nil) }

        OperationQueue().addOperation{
            if let data = try? Data(contentsOf: url){
                OperationQueue.main.addOperation {
                    completion(data)
                }
            } else {
                print("Error getting an image from URL: ", urlString)

                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
        }
    }
}
