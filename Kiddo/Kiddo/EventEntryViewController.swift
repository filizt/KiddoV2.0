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
    private var imageTestData = [String: [String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteUserDefaultsData()
        // createDateObjects()
         populateTestData()
         saveTestData()

        //downloadEventImagesFromSource()
        //downloadEventImagesFromLocalSource()

        //createImageTestData()
        //uploadEventImagesFromLocalSource()

        navigationController?.popViewController(animated: true)
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
                let imagePFFile = PFFile(data: imageData, contentType: "image/jpeg")
                imagePFFile.saveInBackground(block: { (success, error) in
                    eventObject["photo"] = imagePFFile
                    eventObject.saveInBackground()
                })
            }
        }

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
        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-06-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "9:30 AM"
        data["endTime"] = "12:00 AM"
        data["free"] = false
        data["price"] = "0-3 FREE / 4 -12 16.95 / 13 and older 24.95"
        data["originalEventURL"] = "http://www.seattleaquarium.org/"
        data["location"] = "Seattle Aquarium"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "1483 Alaskan Way, Seattle, WA 98101"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "hsoUX77tUB"

        testData["1"] =  data


        data = [String: Any]()
        data["title"] = "Toddler Indoor Playground"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-06-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-08-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-10-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-13-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-15-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-20-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-22-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-27-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-29-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-31-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from:"02-17-2017")
        data["endDate"] = DateUtil.shared.createDate(from:"03-30-2017")
        data["allDay"] = false
        data["startTime"] = "10:00 AM"
        data["endTime"] = "2:00 PM"
        data["free"] = true
        data["price"] = ""
        data["originalEventURL"] = "http://www.seattle.gov/parks/find/centers/montlake-community-center"
        data["location"] = "Montlake Community Center"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "1618 E Calhoun St Seattle, WA 98112"
        data["description"] = "Offered on specific days for a limited amount of time. Toddler Gyms offer a better variety of toys and a much larger space to play in Children will enjoy toys, balls, trikes, scooters, push bikes, and more. Parental supervision required."
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "9CDJILVPf4"
        testData["2"] =  data

////https://img.vimbly.com/images/full_photos/kids-indoor-play-5.jpg

        data = [String: Any]()
        data["title"] = "Dr. Seuss Green Eggs & Ham"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "03-04-2017")
        data["endDate"] = DateUtil.shared.createDate(from:"03-04-2017")
        data["allDay"] = false
        data["startTime"] = "11:00 AM"
        data["endTime"] = "12:00 PM"
        data["free"] = false
        data["price"] = "$15.00 - $20.00"
        data["originalEventURL"] = "http://www.seattlesymphony.org/concerttickets/calendar/2016-2017/symphony/dr-seuss-green-eggs-ham"
        data["location"] = "Beneroya Hall"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "825 228th Ave SE Sammamish, WA 98075"
        data["description"] = "Do you like Green Eggs and Ham?” Spend your Saturday with Sam-I-Am and a Seussical Diva in this orchestral celebration of Dr. Seuss classic culinary curiosity. The Seattle Symphony, partnering with the vaudeville-inspired troupe Really Inventive Stuff, presents Rob Kapilow's delightful composition a musical feast for the whole family. Classical KING FM Family Concerts are designed for ages 12 and below.Come early for pre-concert activities in the Samuel & Althea Stroum Grand Lobby, featuring crafts and an instrument petting zoo."
        data["ages"] = "0 - 12"
        data["imageURL"] = ""
//http://a1.mzstatic.com/us/r1000/041/Purple/4b/19/e2/mzi.anpnlkza.png
        data["imageObjectId"] = "yB4ZLIF7Ig"
        testData["3"] =  data



        data = [String: Any]()
        data["title"] = "Baby Jam"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-10-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-17-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "10:30 AM"
        data["endTime"] = "11:00 PM"
        data["free"] = false
        data["price"] = "Drop-in: $12 per child"
        data["originalEventURL"] = "http://www.babyjam.net/"
        data["location"] = "Balance Studio"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "418 N 35th St, Seattle WA 98103"
        data["description"] = "Seattle Baby Jam is an award winning music class for kids ages birth to 5 years old. Preschoolers, toddlers, babies, and kids from all backgrounds are welcome to attend. We offer fun, engaging, safe, low-pressure rhythm and music exposure for young ones. Help nurture your child's cognitive development through hands-on drumming, percussion, and multilingual songs, stories and games. "
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "lMNL3tWnQj"
        testData["4"] =  data

        data = [String: Any]()
        data["title"] = "Family Nature Classes"
        allEventDates = [Date]()
        print(DateUtil.shared.createDate(from: "02-16-2017 00:00"))
        print(DateUtil.shared.createDate(from: "03-18-2017 00:00"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-23-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-25-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "09:30 AM"
        data["endTime"] = "11:30 PM"
        data["free"] = false
        data["price"] = "$18 for 1 adult and 1 child. Additional child: $9"
        data["originalEventURL"] = "https://www.arboretumfoundation.org/events/"
        data["location"] = "Washington Park Arboretum Graham Visitors Center"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "2300 Arboretum Drive E Seattle, WA 98112"
        data["description"] = "Get outside with your preschooler, foster curiosity and explore the natural world. Our weekly two-hour classes engage the senses with hands on-activities, science-based exploration, learning stations, songs, stories, hikes and games based around a theme that changes every week. "
        data["ages"] = "2 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "nOqZWaOIfj"
        testData["5"] = data

        data = [String: Any]()
        data["title"] = "Penguin Exhibit"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-23-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-25-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = true
        data["startTime"] = ""
        data["endTime"] = ""
        data["free"] = false
        data["price"] = "October 1 - March 31 Adult (13 - 64 years) - $14.95 Child (3-12 years) - $9.95 Toddler (0 - 2 years) - FREE Senior (65+) and disabled discount - $2 off regular admission - (Only available at zoo gates, not online). April 1 - September 30: Adult (13 - 64 years) - $20.95 Child (3-12 years) - $12.95 Toddler (0 - 2 years) - FREE Senior (65+) and disabled discount - $2 off regular admission - (Only available at zoo gates, not online)."
        data["originalEventURL"] = "http://www.zoo.org/exhibits/penguins#.WKHug7YrI_V"
        data["location"] = "Woodland Park Zoo"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "5500 Phinney Ave. N., Seattle WA 98103"
        data["description"] = "Most people think of snow and ice when they think of penguins, but our penguins are from the hot, arid coastal regions of Peru! This award-winning exhibit incorporates a rocky coast with incredible underwater viewing. It is also the first sustainable penguin exhibit with geothermal warming and cooling of water and eco-friendly water filtering systems. Watch up-close as the birds frolic just inches away. May 1 - September 30 Open 9:30 a.m. - 6:00 p.m. daily."
        data["ages"] = "0 - 12"
        data["imageURL"] = ""
        data["imageObjectId"] = "nOqZWaOIfj"
        testData["6"] = data

        data = [String: Any]()
        data["title"] = "Family Swim"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "11:30 AM"
        data["endTime"] = "12:00 AM"
        data["free"] = false
        data["price"] = "$10 for 1 adult and 1 child."
        data["originalEventURL"] = "https://www.seattle.gov/parks/find/pools/rainier-beach-pool/rainier-beach-pool-schedule"
        data["location"] = "Rainier Beach Pool"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "8825 Rainier Ave S, Seattle, WA 98118"
        data["description"] = "Come enjoy your time with your kiddo at Family Swim time at Rainier Beach Pool (Intended for children 5 and under with a parent)."
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "F3atgAj0Dv"
        testData["7"] = data

        data = [String: Any]()
        data["title"] = "Family Stroy Time"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "10:30 AM"
        data["endTime"] = "11:30 AM"
        data["free"] = true
        data["price"] = ""
        data["originalEventURL"] = "http://www.spl.org/audiences/children/chi-calendar-of-events"
        data["location"] = "SPL Lake City Branch"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "12501 28th Ave NE, Seattle, WA 98125"
        data["description"] = "It is story time at the Lake City Branch! Bring your children from birth to age 8 to enjoy stories, rhymes, songs, crafts, and fun with our children's librarian, Nancy P! Space is limited at library events. Please come early to make sure you get a seat. Due to the fire code, we can’t exceed the maximum capacity for our rooms."
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["imageObjectId"] = "IGisjfW4B9"
        testData["8"] = data

        data = [String: Any]()
        data["title"] = "Coffee Shop & Kids Indoor Activity"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = true
        data["startTime"] = ""
        data["endTime"] = ""
        data["free"] = false
        data["price"] = "Day Pass: $6/child (unlimited play time) 30 Day Pass: $15/child (unlimited visits) 12 Month Pass: $150/child (unlimited visits)"
        data["originalEventURL"] = "http://wunderkindseattle.com/"
        data["location"] = "Wunderkind Seattle"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "3318 NE 55th St, Seattle, WA 98105"
        data["description"] = "Keep kiddos busy with legos, train sets and duplo while you sip your coffee. Ages 18 months – 4 years: Our main floor play space features an extensive area tailored specifically for younger kids ages 18 months to 4 years. They’ll have an opportunity to create whatever may pop into their imagination using a seemingly endless supply of LEGO® DUPLO® building blocks, train sets, and figures on early 65 square feet of counter space built at just the right height.Ages 4 and up: Older kids will find an equally appealing space in our community build area upstairs where they can build more advanced structures, motorized vehicles, and other unique creations using LEGO® building blocks. We also work to maintain their interests by exploring different themes so they may find a different look and feel from one visit to the next. Daily 9:00AM to 6:00 PM"
        data["ages"] = "0 - 12"
        data["imageURL"] = ""
        data["imageObjectId"] = "st61S1cRPT"
        testData["9"] = data

    }

    func saveTestData() {

            for entry in self.testData {
                if let test = self.testData[entry.key] {
                    let eventObject: PFObject = PFObject(className: "EventObject")
                    eventObject["title"] = test["title"]
                    eventObject["allEventDates"] = test["allEventDates"] as! [Date];
                    eventObject["startDate"] = test["startDate"] as! Date
                    eventObject["endDate"] = test["endDate"] as! Date
                    eventObject["allDay"] = test["allDay"] as! Bool
                    eventObject["startTime"] = test["startTime"] as? String
                    eventObject["endTime"] = test["endTime"] as? String
                    eventObject["free"] = test ["free"] as! Bool
                    eventObject["price"] =  test["price"] as! String
                    eventObject["originalEventURL"] = test["originalEventURL"] as! String
                    eventObject["location"] = test["location"] as! String
                    eventObject["locationHours"] = test["locationHours"] as! String
                    eventObject["address"] = test["address"] as! String
                    eventObject["description"] = test["description"] as! String
                    eventObject["ages"] = test["ages"] as! String
                    eventObject["imageURL"] = test["imageURL"] as! String
                    eventObject["imageObjectId"] = test["imageObjectId"] as! String

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

    }

    private func downloadEventImagesFromSource() {
        let query = PFQuery(className: "EventObject")
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                for eventObject in objects {
                    guard let url = eventObject["imageURL"] else { continue }
                    self.getImageData(urlString: url as! String) { (imageData) in
                        if let imageData = imageData {
                            let imagePFFile = PFFile(data: imageData, contentType: "image/jpeg")
                            imagePFFile.saveInBackground(block: { (success, error) in
                                eventObject["photo"] = imagePFFile
                                eventObject.saveInBackground()
                            })
                        }
                    }
                }
            }
        }
    }


    private func downloadEventImagesFromLocalSource() {
        let query = PFQuery(className: "EventObject")

            if let objects = try? query.findObjects() {
                for eventObject in objects {
                    guard let fileName = eventObject["imageObjectId"] as? String else { continue }

                    if let imageFileURL = Bundle.main.url(forResource: fileName, withExtension: "jpg", subdirectory: "Assets") {
                        if let imageData = try? Data(contentsOf: imageFileURL) {
                            let imagePFFile = PFFile(data: imageData, contentType: "image/jpeg")
                            eventObject["photo"] = imagePFFile
                            if let imagePFFile = try? imagePFFile.save() {
                                //eventObject["photo"] = imagePFFile
                            }
                            guard let _ = try? eventObject.save() else { return }
                        }
                    }
                }
            }
    }

    private func createImageTestData() {
        var imageData = [String: Any]()
        imageData["category"] = "Swimming"
        imageData["imageName"] = "Swimming"
        imageTestData["0"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Aquarium"
        imageData["imageName"] = "Aquarium"
        imageTestData["1"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "BabyJam"
        imageData["imageName"] = "Swimming"
        imageTestData["2"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Brewery"
        imageData["imageName"] = "Brewery"
        imageTestData["3"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Coffeeshop"
        imageData["imageName"] = "Coffeeshop"
        imageTestData["4"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "IndoorGym"
        imageData["imageName"] = "IndoorGym"
        imageTestData["5"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Library"
        imageData["imageName"] = "Library"
        imageTestData["6"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "LoginScreen"
        imageData["imageName"] = "LoginScreen"
        imageTestData["7"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Music"
        imageData["imageName"] = "Music"
        imageTestData["8"] = imageData

        imageData = [String: Any]()
        imageData["category"] = "Zoo"
        imageData["imageName"] = "Zoo"
        imageTestData["9"] = imageData

    }

    private func uploadEventImagesFromLocalSource() {

        for entry in self.imageTestData {
            if let test = self.imageTestData[entry.key] {
                let eventImage = PFObject(className: "EventImage")
                eventImage["category"] = test["category"] as! String
                eventImage["imageName"] = test["imageName"] as! String

                if let imageFileURL = Bundle.main.url(forResource: eventImage["imageName"] as! String?, withExtension: "jpg", subdirectory: "Assets") {
                    if let imageData = try? Data(contentsOf: imageFileURL) {
                        let imagePFFile = PFFile(data: imageData, contentType: "image/jpeg")
                        eventImage["image"] = imagePFFile
                        if let imagePFFile = try? imagePFFile.save() {
                            //image saved. Now try save eventImage object
                             guard let _ = try? eventImage.save() else { return }
                        } else {
                            print("IMAGE IS NOT SAVED!!!")
                        }
                    }
                }
            }
        }
    }


    private func createDateObjects() {
        var allEventDates = [Date]()
        let eventDate1 = DateUtil.shared.createDate(from: "04-02-2017 10:00")
        allEventDates.append(eventDate1)

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
