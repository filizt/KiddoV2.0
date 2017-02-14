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
    let date: Date!
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

    static func create(from object: PFObject) -> Event {
        let id = object.objectId ?? "0"
        let title = object["title"] as! String
        let date = (object["allEventDates"] as! [Date]).first
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
        let originalEventURL = object["originalEventURL"] as? String
        let address = object["address"] as! String
        let description = object["description"] as! String
        let ages = object["ages"] as! String
        let photo = object["photo"] as? PFFile

        return Event(id: id,
                     title: title,
                     date: date,
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
                     photo: photo
        )
    }
}


