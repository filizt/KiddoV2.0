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
    let startDate: Date
    let endDate: Date
    let allDayFlag: Bool!
    let startTime: String
    let endTime: String
    let freeFlag: Bool!
    let price: String
    let location: String!
    let locationHours: String
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

    static var pushedEventId: String?
    static var pushedEvent: Event?

    static func create(from object: PFObject) -> Event {
        let id = object.objectId ?? "0"
        let title = object["title"] as! String
        let dates = object["allEventDates"] as! [Date] //force downcast
        let startDate = object["startDate"] as! Date
        let endDate = object["endDate"] as! Date
        let allDayFlag = object["allDay"] as! Bool
        let startTime = object["startTime"] as! String
        let endTime = object["endTime"] as! String
        let freeFlag = object["free"] as! Bool
        let price = object["price"] as! String
        let location = object["location"] as! String
        let locationHours = object["locationHours"] as! String
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

        return Event(id: id,
                     title: title,
                     dates: dates,
                     startDate: startDate,
                     endDate: endDate,
                     allDayFlag: allDayFlag,
                     startTime: startTime,
                     endTime: endTime,
                     freeFlag: freeFlag,
                     price: price,
                     location: location,
                     locationHours: locationHours,
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
                     categoryKeywords: categoryKeywords
        )
    }

    mutating func updateDates(bydate: Date) {
        dates = dates.filter{ $0 >= bydate }
    }

    static func parseImageId(object: PFObject) -> String {
       return object["imageObjectId"] as! String
    }
}


