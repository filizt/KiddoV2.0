//
//  FilterUtil.swift
//  Kiddo
//
//  Created by Filiz Kurban on 9/7/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation

//Look how to make these work with the masks
enum FilterCriteria: Int {
    case theme = 1
    case cost = 2
    case date = 4
}

class FilterUtil {

    class func sort(events: [Event]) -> [Event] {
        var e = events
        var a = e.filter { $0.allDayFlag == false }
        let b = e.filter { $0.allDayFlag == true }
        a.sort { ($0.startTime < $1.startTime) }
        e = a + b

        return e
    }

//    class func filterBy(criteria: FilterCriteria, events: [Event]) -> [Event] {
//        switch(criteria) {
//        case .theme
//
//        }
//    }



}
