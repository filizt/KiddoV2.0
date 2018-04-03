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
    var eventDates: [Date]
    let allDayFlag: Bool!
    let startTime: Date
    let endTime: Date
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
    let eventInstances: [(Date, Date)]!
    let ticketsURL: String
    let discountedTicketInstances: [[String:Date]]
    let discountedTicketsURL: String
    let variousTimes: Bool!
    let discountedTicketPrice: String
    let activeEventInstanceIndex: Int

    static var pushedEventId: String?
    static var pushedEvent: Event?
    static var pushedEventForDateTime: String?

    static func create(from object: PFObject, forDay: String) -> Event {
        let id = object.objectId ?? "0"
        let title = object["title"] as! String
        var eventDates = object["allEventDates"] as! [Date] //force downcast
        let allDayFlag = object["allDay"] as! Bool
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
        let activeEventInstanceIndex = 0

        let ticketsURL = object["ticketsURL"] as! String
        let discountedTicketInstances = object["discountedTicketInstances"] as! [[String:Date]]
        let discountedTicketsURL = object["discountedTicketsURL"] as! String
        let discountedTicketPrice = object["discountedTicketPrice"] as! String

        //Find the particular event Instance we're showing in the evetInstances dictionary.

        var startTime = Date()//NEED TO FX THIS LATER!!!
        var endTime = Date()
        var variousTimes = false
        let instances = object["eventInstances"] as! [[String:Date]]
        var eventInstances = [(Date,Date)]()

        switch forDay {
        case "Today" :
            if let startDate = DateUtil.shared.todayStart(), let endDate = DateUtil.shared.addOneDay(startDate: startDate) {
               //  eventDateTimeList.contains(where: { $0 == (startDateTime, endDateTime) }
                //var todayInstance = eventInstances.first(where: $0)
               // var eventInstances = localEventInstances.flatMap { $0.filter { $0.key == "startTime" && ($0.value >= startDate && $0.value < endDate ) } }
                for instanceDict in instances {
                    if let value = instanceDict["startTime"] {
                        if value >= startDate && value < endDate {
                            let start = value
                            if let end = instanceDict["endTime"] {
                                eventInstances.append((start,end))
                            }
                        }
                    }
                }

                if eventInstances.count > 1 {
                    variousTimes = true
                }
            }

        case "Tomorrow" :
            if let startDate = DateUtil.shared.tomorrowStart(), let endDate = DateUtil.shared.addOneDay(startDate: startDate) {

                for instanceDict in instances {
                    if let value = instanceDict["startTime"] {
                        if value >= startDate && value < endDate {
                            let start = value
                            if let end = instanceDict["endTime"] {
                                eventInstances.append((start,end))
                            }
                        }
                    }
                }

                if eventInstances.count > 1 {
                    variousTimes = true
                }
            }

        case "Later" :
            if let startDate = DateUtil.shared.laterStart() {

                eventDates = eventDates.filter{ $0 >= startDate }

                for instanceDict in instances {
                    if let value = instanceDict["startTime"] {
                        if value >= startDate {
                            let start = value
                            if let end = instanceDict["endTime"] {
                                eventInstances.append((start,end))
                            }
                        }
                    }
                }

                //for later events eventInstances should be context aware and show only event instances for the first date the event occurs
                let d = eventInstances.first?.0
                let s = DateUtil.shared.customStart(from:d!)!
                let e = DateUtil.shared.addOneDay(startDate:s)!

                eventInstances = eventInstances.filter { ($0.0 >= s && $0.0 < e) }

            }

        case "PushedEvent" :

            if let startDate = DateUtil.shared.dateStringToDateObject(dateString: pushedEventForDateTime!), let endDate = DateUtil.shared.addOneDay(startDate: startDate) {
                //  eventDateTimeList.contains(where: { $0 == (startDateTime, endDateTime) }
                //var todayInstance = eventInstances.first(where: $0)
                // var eventInstances = localEventInstances.flatMap { $0.filter { $0.key == "startTime" && ($0.value >= startDate && $0.value < endDate ) } }
                for instanceDict in instances {
                    if let value = instanceDict["startTime"] {
                        if value >= startDate && value < endDate {
                            let start = value
                            if let end = instanceDict["endTime"] {
                                eventInstances.append((start,end))
                            }
                        }
                    }
                }

                if eventInstances.count > 1 {
                    variousTimes = true
                }
            }
        default:
            print("hit default")
        }

        startTime = (eventInstances.first?.0)!
        endTime = (eventInstances.first?.1)!

        return Event(id: id,
                     title: title,
                     eventDates: eventDates,
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
                     eventInstances: eventInstances,
                     ticketsURL: ticketsURL,
                     discountedTicketInstances: discountedTicketInstances,
                     discountedTicketsURL: discountedTicketsURL,
                     variousTimes: variousTimes,
                     discountedTicketPrice: discountedTicketPrice,
                     activeEventInstanceIndex: activeEventInstanceIndex
        )
    }
//
//
//    mutating func updateDates(bydate: Date) {
//        dates = dates.filter{ $0 >= bydate }
//    }

}


