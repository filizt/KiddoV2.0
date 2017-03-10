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
         //populateTestData()
         //saveTestData()

        //downloadEventImagesFromSource()
        //downloadEventImagesFromLocalSource()

        createImageTestData()
        uploadEventImagesFromLocalSource()

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
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-06-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-07-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-08-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-09-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-10-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-11-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-12-2017"))
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
        data["locationHours"] = ""
        data["address"] = "1483 Alaskan Way, Seattle, WA 98101"
        data["description"] = "From dressing up like a wolf eel to fish-print painting and water play with ocean animal toys, Toddler Time keeps even the busiest of bodies engaged and entertained. A myriad of developmentally age-appropriate, hands-on activities await for tots to explore."
        data["ages"] = "0 - 5"
        data["imageURL"] = ""
        data["isActive"] = true
        data["isPopular"] = true
        data["imageObjectId"] = "upisg34kPs"

        testData["1"] =  data


//        data = [String: Any]()
//        data["title"] = "Toddler Indoor Playground"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-06-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-08-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-10-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-13-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-15-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-20-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-22-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-27-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-29-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-31-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from:"02-17-2017")
//        data["endDate"] = DateUtil.shared.createDate(from:"03-30-2017")
//        data["allDay"] = false
//        data["startTime"] = "10:00 AM"
//        data["endTime"] = "2:00 PM"
//        data["free"] = true
//        data["price"] = ""
//        data["originalEventURL"] = "http://www.seattle.gov/parks/find/centers/montlake-community-center"
//        data["location"] = "Montlake Community Center"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "1618 E Calhoun St Seattle, WA 98112"
//        data["description"] = "Offered on specific days for a limited amount of time. Toddler Gyms offer a better variety of toys and a much larger space to play in Children will enjoy toys, balls, trikes, scooters, push bikes, and more. Parental supervision required."
//        data["ages"] = "0 - 5"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "tz76WpiHYe"
//        testData["2"] =  data

////https://img.vimbly.com/images/full_photos/kids-indoor-play-5.jpg

        data = [String: Any]()
        data["title"] = "Tiny Tyke Time"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-06-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-07-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-08-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-09-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-10-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-11-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-12-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "03-04-2017")
        data["endDate"] = DateUtil.shared.createDate(from:"03-04-2017")
        data["allDay"] = false
        data["startTime"] = "09:00 AM"
        data["endTime"] = "10:30 AM"
        data["free"] = false
        data["price"] = "$100 per 6-week session each parent/child pair"
        data["originalEventURL"] = "http://www.seattlesymphony.org/concerttickets/calendar/2016-2017/symphony/dr-seuss-green-eggs-ham"
        data["location"] = "Woodland Park Zoo"
        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
        data["address"] = "825 228th Ave SE Sammamish, WA 98075"
        data["description"] = "Experience the zoo through the eyes of your child. Watch your toddler play and discover in Zoomazium before it opens. Then, each week set out to explore a different part of the zoo. With an experienced guide you and your child will discover the amazing animals that inhabit each region and figure out if they are slimy, scaly, feathery, or furry and much more."
        data["ages"] = "0 - 12"
        data["imageURL"] = ""
//http://a1.mzstatic.com/us/r1000/041/Purple/4b/19/e2/mzi.anpnlkza.png
        data["imageObjectId"] = "xGOoXPL3kR"
        data["isActive"] = true
        data["isPopular"] = true
        testData["2"] =  data



//        data = [String: Any]()
//        data["title"] = "Baby Jam"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-15-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-10-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from: "02-17-2017")
//        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
//        data["allDay"] = false
//        data["startTime"] = "10:30 AM"
//        data["endTime"] = "11:00 PM"
//        data["free"] = false
//        data["price"] = "Drop-in: $12 per child"
//        data["originalEventURL"] = "http://www.babyjam.net/"
//        data["location"] = "Balance Studio"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "418 N 35th St, Seattle WA 98103"
//        data["description"] = "Seattle Baby Jam is an award winning music class for kids ages birth to 5 years old. Preschoolers, toddlers, babies, and kids from all backgrounds are welcome to attend. We offer fun, engaging, safe, low-pressure rhythm and music exposure for young ones. Help nurture your child's cognitive development through hands-on drumming, percussion, and multilingual songs, stories and games. "
//        data["ages"] = "0 - 5"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "XCqOt5xlh4"
//        testData["4"] =  data

        data = [String: Any]()
        data["title"] = "Little Movers"
        allEventDates = [Date]()
        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-06-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-07-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-08-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-09-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-10-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-11-2017"))
        allEventDates.append(DateUtil.shared.createDate(from: "03-12-2017"))
        data["allEventDates"] = allEventDates
        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
        data["allDay"] = false
        data["startTime"] = "10:30 AM"
        data["endTime"] = "11:15 AM"
        data["free"] = true
        data["price"] = ""
        data["originalEventURL"] = "https://www.arboretumfoundation.org/events/"
        data["location"] = "Seattle Public Library"
        data["locationHours"] = ""
        data["address"] = "1000 Fourth Ave. Seattle, WA 98104"
        data["description"] = "The Seattle Public Library will host free sessions of Illumination Learning's \"Little Movers\" a music class for toddlers and their parents or caregivers. Little Movers is an introduction into the world of music for children ages 15 months to 3 years old. Library events are free and open to the public. Free parking is available in the underground garage. Enter and exit the garage on N. 81st Street. Registration is required, call or drop by the branch to sign up."
        data["ages"] = "15 months - 3 years old"
        data["imageURL"] = ""
        data["imageObjectId"] = "o32UnQpsZF"
        data["isActive"] = true
        data["isPopular"] = false
        testData["3"] = data

//        data = [String: Any]()
//        data["title"] = "Penguin Exhibit"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-23-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-25-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
//        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
//        data["allDay"] = true
//        data["startTime"] = ""
//        data["endTime"] = ""
//        data["free"] = false
//        data["price"] = "October 1 - March 31 Adult (13 - 64 years) - $14.95 Child (3-12 years) - $9.95 Toddler (0 - 2 years) - FREE Senior (65+) and disabled discount - $2 off regular admission - (Only available at zoo gates, not online). April 1 - September 30: Adult (13 - 64 years) - $20.95 Child (3-12 years) - $12.95 Toddler (0 - 2 years) - FREE Senior (65+) and disabled discount - $2 off regular admission - (Only available at zoo gates, not online)."
//        data["originalEventURL"] = "http://www.zoo.org/exhibits/penguins#.WKHug7YrI_V"
//        data["location"] = "Woodland Park Zoo"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "5500 Phinney Ave. N., Seattle WA 98103"
//        data["description"] = "Most people think of snow and ice when they think of penguins, but our penguins are from the hot, arid coastal regions of Peru! This award-winning exhibit incorporates a rocky coast with incredible underwater viewing. It is also the first sustainable penguin exhibit with geothermal warming and cooling of water and eco-friendly water filtering systems. Watch up-close as the birds frolic just inches away. May 1 - September 30 Open 9:30 a.m. - 6:00 p.m. daily."
//        data["ages"] = "0 - 12"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "aj6irGvQ5J"
//        testData["6"] = data

//        data = [String: Any]()
//        data["title"] = "Family Swim"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
//        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
//        data["allDay"] = false
//        data["startTime"] = "11:30 AM"
//        data["endTime"] = "12:00 AM"
//        data["free"] = false
//        data["price"] = "$10 for 1 adult and 1 child."
//        data["originalEventURL"] = "https://www.seattle.gov/parks/find/pools/rainier-beach-pool/rainier-beach-pool-schedule"
//        data["location"] = "Rainier Beach Pool"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "8825 Rainier Ave S, Seattle, WA 98118"
//        data["description"] = "Come enjoy your time with your kiddo at Family Swim time at Rainier Beach Pool (Intended for children 5 and under with a parent)."
//        data["ages"] = "0 - 5"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "gJQpn5LTJL"
//        testData["7"] = data

//        data = [String: Any]()
//        data["title"] = "Family Story Time"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
//        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
//        data["allDay"] = false
//        data["startTime"] = "10:30 AM"
//        data["endTime"] = "11:30 AM"
//        data["free"] = true
//        data["price"] = ""
//        data["originalEventURL"] = "http://www.spl.org/audiences/children/chi-calendar-of-events"
//        data["location"] = "SPL Lake City Branch"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "12501 28th Ave NE, Seattle, WA 98125"
//        data["description"] = "It is story time at the Lake City Branch! Bring your children from birth to age 8 to enjoy stories, rhymes, songs, crafts, and fun with our children's librarian, Nancy P! Space is limited at library events. Please come early to make sure you get a seat. Due to the fire code, we can’t exceed the maximum capacity for our rooms."
//        data["ages"] = "0 - 5"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "cl3E2YnoCU"
//        testData["8"] = data

//        data = [String: Any]()
//        data["title"] = "Coffee Shop & Kids Indoor Activity"
//        allEventDates = [Date]()
//        allEventDates.append(DateUtil.shared.createDate(from: "02-16-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-17-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-18-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-19-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-20-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-21-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-22-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-23-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-24-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-25-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-26-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-27-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "02-28-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-01-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-02-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-03-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-04-2017"))
//        allEventDates.append(DateUtil.shared.createDate(from: "03-05-2017"))
//        data["allEventDates"] = allEventDates
//        data["startDate"] = DateUtil.shared.createDate(from: "02-16-2017")
//        data["endDate"] = DateUtil.shared.createDate(from: "03-31-2017")
//        data["allDay"] = true
//        data["startTime"] = ""
//        data["endTime"] = ""
//        data["free"] = false
//        data["price"] = "Day Pass: $6/child (unlimited play time) 30 Day Pass: $15/child (unlimited visits) 12 Month Pass: $150/child (unlimited visits)"
//        data["originalEventURL"] = "http://wunderkindseattle.com/"
//        data["location"] = "Wunderkind Seattle"
//        data["locationHours"] = "9 AM to 5 PM daily. Closed on Sundays."
//        data["address"] = "3318 NE 55th St, Seattle, WA 98105"
//        data["description"] = "Keep kiddos busy with legos, train sets and duplo while you sip your coffee. Ages 18 months – 4 years: Our main floor play space features an extensive area tailored specifically for younger kids ages 18 months to 4 years. They’ll have an opportunity to create whatever may pop into their imagination using a seemingly endless supply of LEGO® DUPLO® building blocks, train sets, and figures on early 65 square feet of counter space built at just the right height.Ages 4 and up: Older kids will find an equally appealing space in our community build area upstairs where they can build more advanced structures, motorized vehicles, and other unique creations using LEGO® building blocks. We also work to maintain their interests by exploring different themes so they may find a different look and feel from one visit to the next. Daily 9:00AM to 6:00 PM"
//        data["ages"] = "0 - 12"
//        data["imageURL"] = ""
//        data["imageObjectId"] = "Mi2n2k4SMK"
//        testData["9"] = data

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
                    eventObject["isActive"] = test["isActive"] as! Bool
                    eventObject["isPopular"] = test["isPopular"] as! Bool

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
//        imageData["category"] = "Category"
//        imageData["imageName"] = "AquariumMammal"
//        imageTestData["0"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "aquarium2"
//        imageTestData["1"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "ArtsGeneric"
//        imageTestData["2"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "ArtsGeneric2"
//        imageTestData["3"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "ArtsPainting"
//        imageTestData["4"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "ArtsPaintingKid"
//        imageTestData["5"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Baby"
//        imageTestData["6"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Clover"
//        imageTestData["7"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Coffeeshop"
//        imageTestData["8"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "EMPlicensed"
//        imageTestData["9"] = imageData
//
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "IndoorGym"
//        imageTestData["10"] = imageData
//
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "IndoorPlayGeneric"
//        imageTestData["11"] = imageData
//
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "KidSwimming"
//        imageTestData["12"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Library2"
//        imageTestData["13"] = imageData
//
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "LibraryGeneric"
//        imageTestData["14"] = imageData
//
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "MusicGeneric"
//        imageTestData["15"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorBuble"
//        imageTestData["16"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorGeneric"
//        imageTestData["17"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorGeneric2"
//        imageTestData["18"] = imageData
//
//        imageData = [String: Any]()
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorJump"
//        imageTestData["19"] = imageData
//
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorKidPlay"
//        imageTestData["20"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "OutdoorLeaves"
//        imageTestData["21"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "PacificScienceCenter"
//        imageTestData["22"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "PeppaPig"
//        imageTestData["23"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Pony"
//        imageTestData["24"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "PuppetShow"
//        imageTestData["25"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Swimming"
//        imageTestData["26"] = imageData
//        imageData = [String: Any]()
//        
//        imageData["category"] = "Category"
//        imageData["imageName"] = "TheatreGeneric"
//        imageTestData["27"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Thomas"
//        imageTestData["28"] = imageData
//        imageData = [String: Any]()
//
//        imageData["category"] = "Category"
//        imageData["imageName"] = "Yoga"
//        imageTestData["29"] = imageData
//        imageData = [String: Any]()

        imageData["category"] = "Category"
        imageData["imageName"] = "Zoomazium"
        imageTestData["0"] = imageData
        imageData = [String: Any]()

        imageData["category"] = "Category"
        imageData["imageName"] = "Elmo"
        imageTestData["1"] = imageData
        imageData = [String: Any]()


        

    }

    private func uploadEventImagesFromLocalSource() {

        print ("Start uploading")

        for entry in self.imageTestData {
            if let test = self.imageTestData[entry.key] {
                let eventImage = PFObject(className: "EventImage")
                eventImage["category"] = test["category"] as! String
                eventImage["imageName"] = test["imageName"] as! String

                if let imageFileURL = Bundle.main.url(forResource: eventImage["imageName"] as! String?, withExtension: "jpeg", subdirectory: "Assets") {
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
