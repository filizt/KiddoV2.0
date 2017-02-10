//
//  Event.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

struct Event {
    let id: String
    let title: String
    let startDate: Date?
    let endDate: Date?
    let location: String?
    let imageURL: String?
    let allDayFlag: Bool
    let freeFlag: Bool
    let originalEventURL: String?
    let price: String?
    let address: String?
    let description: String?
    let photo: PFFile?

    static func create(from object: PFObject) -> Event {
        let id = object.objectId ?? "0"
        let title = object["title"] as! String
        let startDate = object["startDate"] as? Date
        let endDate = object["endDate"] as? Date
        let location = object["location"] as? String
        let imageURL = object["imageURL"] as? String
        let allDayFlag = object["allDay"] as! Bool
        let freeFlag = object["free"] as! Bool
        let originalEventURL = ""
        let price = object["price"] as? String
        let address = object["address"] as? String
        let description = object["description"] as? String
        let photo = object["photo"] as? PFFile

        return Event(id: id,
                     title: title,
                     startDate: startDate,
                     endDate: endDate,
                     location: location,
                     imageURL: imageURL,
                     allDayFlag: allDayFlag,
                     freeFlag: freeFlag,
                     originalEventURL: originalEventURL,
                     price: price,
                     address: address,
                     description: description,
                     photo: photo
        )
    }
}


//    init?(jsonDictionary: [String: Any]) {
//        
//        if let eventTitle = jsonDictionary["title"] as? String {
//            if let alldayFlag = jsonDictionary["all_day"] as? String, (alldayFlag == "2" || alldayFlag == "1") {
//                self.allDayFlag = true
//            } else {
//                self.allDayFlag = false
//            }
//
//            self.eventTitle = eventTitle
//            self.eventVenueName = jsonDictionary["venue_name"] as? String
//            self.eventDescription = jsonDictionary["description"] as? String
//            self.eventAddress = jsonDictionary["venue_address"] as? String
//            self.eventUrl = jsonDictionary["url"] as? String
//            
//            let eventDate = jsonDictionary["start_time"] as? String
//            var newTimeString:String? = nil
//            var newDateString:String? = nil
//            if eventDate?.isEmpty != true {
//                let dateFormatter = DateFormatter()
//                dateFormatter.timeZone = TimeZone(identifier: "GMT")
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//                if let date = dateFormatter.date(from: eventDate!) {
//                    dateFormatter.dateFormat = "HH:mm"
//                    dateFormatter.timeStyle = .short
//                    newTimeString = dateFormatter.string(from: date)
//
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    dateFormatter.timeStyle = .long
//                    newDateString = dateFormatter.string(from: date)
//
//                }
//            }
//            self.eventDate = newDateString
//            self.eventStartTime = newTimeString
//
//
//
//
//        // if let constants only scope down into the if statement
//            
////        if let eventPrice = jsonDictionary["price"] as? String {
////            if eventPrice == "" {
////                self.eventPrice = "Free"
////            } else {
////                self.eventPrice = eventPrice
////            }
////        } else {
////            self.eventPrice = "Free"
////        }
////            
//        
//        if let eventImageUrls = jsonDictionary["image"] as? [String:Any] {
//            let key = eventImageUrls.keys.first!
//            let eventImageUrlObject: [String: Any]
//
//            switch key {
//            case "large":
//                eventImageUrlObject = eventImageUrls["large"] as! [String: Any]
//                let eventImageUrl = eventImageUrlObject["url"] as? String
//                self.eventImageUrl = eventImageUrl
//            case "medium":
//                eventImageUrlObject = eventImageUrls["medium"] as! [String: Any]
//                let eventImageUrl = eventImageUrlObject["url"] as? String
//                self.eventImageUrl = eventImageUrl
//            default:
//                self.eventImageUrl = nil
//                print("Default case hit while extracting image URL from JSON")
//            }
//        } else {
//            self.eventImageUrl = nil
//        }
//
//
//                    
//    } else {
//    
//    return nil
//            
//    }
// }

//    func dateFormatter(dateString: String) -> String? {
//        if dateString.isEmpty != true {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:dd"
//
//            if let date = dateFormatter.date(from: dateString) {
//                dateFormatter.dateFormat = "HH:mm:dd"
//                let newDateString = dateFormatter.string(from: date)
//                //print(newDateString)
//                return newDateString
//            }
//        }
//
//        return nil
//
//    }
//

