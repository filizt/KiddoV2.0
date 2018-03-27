//
//  Event.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

struct Event {
    let id: String
    let title: String
    var dates: [Date]
    let allDayFlag: Bool!
    let startTime: String
    let endTime: String
    let freeFlag: Bool!
    let price: String
    let location: String!
    let imageURL: String?
    let originalEventURL: String?
    let address: String!
    let description: String!
    let ages: String
    let photo: PFFile?
    let category: String!
    let featuredFlag: Bool
    var imageObjectId: String!
    let geoLocation: PFGeoPoint?
    let categoryKeywords: [String]?
    let showTimes: String? //Delete this
    let allEventSessions: [Date]
    let ticketsURL: String
    let discountedTicketSessions: [Date]?
    let discountedTicketsURL: String?

    static var pushedEventId: String?
    static var pushedEvent: Event?
    static var pushedEventForDateTime: String?

    static func create(from object: PFObject) -> Event {
        let id = object.objectId ?? "0"
        let title = object["title"] as! String
        let dates = object["allEventDates"] as! [Date] //force downcast
        let allDayFlag = object["allDay"] as! Bool
        let startTime = object["startTime"] as? String ?? ""
        let endTime = object["endTime"] as? String ?? ""
        let freeFlag = object["free"] as! Bool
        let price = object["price"] as! String
        let location = object["location"] as! String
        let imageURL = object["imageURL"] as? String
        let originalEventURL = object["originalEventURL"] as? String //Try downcast; and store nil if doesn't work
        let address = object["address"] as! String
        let description = object["description"] as! String
        let ages = object["ages"] as! String
        let photo = object["photo"] as? PFFile //This might become heavy as we store lots of events.
        let category = object["category"] as! String
        let featuredFlag = object["isFeatured"] as! Bool
        let imageObjectId = object["imageObjectId"] as! String
        let geoLocation = object["geoLocation"] as? PFGeoPoint
        let categoryKeywords = object["categoryKeywords"] as? [String]
        let showTimes = object["showTimes"] as? String
        let allEventSessions = object["allEventSessions"] as! [Date]
        let ticketsURL = object["ticketsURL"] as! String
        let discountedTicketSessions = object["discountedTicketSessions"] as? [Date]
        let discountedTicketsURL = object["discountedTicketsURL"] as? String

        return Event(id: id,
                     title: title,
                     dates: dates,
                     allDayFlag: allDayFlag,
                     startTime: startTime,
                     endTime: endTime,
                     freeFlag: freeFlag,
                     price: price,
                     location: location,
                     imageURL: imageURL,
                     originalEventURL: originalEventURL,
                     address: address,
                     description: description,
                     ages: ages,
                     photo: photo,
                     category: category,
                     featuredFlag: featuredFlag,
                     imageObjectId: imageObjectId,
                     geoLocation: geoLocation,
                     categoryKeywords: categoryKeywords,
                     showTimes: showTimes,
                     allEventSessions: allEventSessions,
                     ticketsURL: ticketsURL,
                     discountedTicketSessions: discountedTicketSessions,
                     discountedTicketsURL: discountedTicketsURL
        )
    }

    mutating func updateDates(bydate: Date) {
        dates = dates.filter{ $0 >= bydate }
    }

    static func parseImageId(object: PFObject) -> String {
       return object["imageObjectId"] as! String
    }
}


