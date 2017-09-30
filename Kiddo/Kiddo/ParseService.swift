//
//  Parse.swift
//  Kiddo
//
//  Created by Filiz Kurban on 9/7/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

typealias fetchEventsCompletion = ([PFObject]) -> ()

class ParseService {

    static let shared = Parse()
    static var lastRequest = PFQuery<PFObject>()

    class func fetchEvents(date: Date, completion: @escaping fetchEventsCompletion) {
        let eventsQuery = PFQuery(className: "EventDate")
        lastRequest = eventsQuery
        let date = DateUtil.shared.createDate(from: DateUtil.shared.today())
        eventsQuery.whereKey("eventDate", equalTo: date)
        eventsQuery.findObjectsInBackground { (dateObjects, error) in
            guard error == nil else {
                print ("Error fetching today's events from Parse")
                return
            }

            if let dateObjects = dateObjects {
                let relation = dateObjects[0].relation(forKey: "events")
                let query = relation.query()
                query.includeKey("isActive")
                query.whereKey("isActive", equalTo: true)
                query.findObjectsInBackground { (objects, error) in
                    if let objects = objects {
                        if lastRequest == eventsQuery {
                            completion(objects)
                        }
                    }
                }
            }
        }
    }

    // Let's check if any data is dirty and needs to be updated in the app.
    class func checkDirty() {
        //what is the best way to check for dirty and update?
    }

}
