//
//  Util.swift
//  Kiddo
//
//  Created by Filiz Kurban on 1/13/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation

class DateUtil {

    private let formatter: DateFormatter
    static let shared = DateUtil()

    private init() {
        formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        //below code is just for now. We want users to at least see something in the UI.
        if TimeZone.current.abbreviation() != "PST" {
            formatter.timeZone = TimeZone(abbreviation:"PST")
        } else {
            formatter.timeZone = TimeZone.current
        }

    }

//    func UTCZeroZeroDateValue(date: Date) -> Date? {
//
//        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: date)
//        components.hour = 0
//        components.minute = 0
//        components.second = 0
//        components.timeZone = TimeZone(abbreviation: "UTC")
//        return Calendar.current.date(from: components)
//    }

    func todayStart() -> Date? {
        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0

        return Calendar.current.date(from: components)
    }
    func tomorrowStart() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 1

        guard let tomorrow = Calendar.current.date(byAdding: dateComponents, to: todayStart()!) else { return nil }

        return tomorrow

    }

    func laterStart() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 1

        guard let later = Calendar.current.date(byAdding: dateComponents, to: tomorrowStart()!) else { return nil }

        return later
    }
    

    func customStart(from date:Date) -> Date? {
        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0

        return Calendar.current.date(from: components)
    }

    func addOneDay(startDate: Date ) -> Date? {
        let date = startDate.addingTimeInterval(24 * 60.0 * 60.0)
        return date
    }

    func addThreeMonths(to date: Date) -> Date? {
        let date = date.addingTimeInterval(90.0 * 24 * 60.0 * 60.0)
        return date
    }

    func dateStringToDateObject(dateString: String) -> Date? {
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let date = formatter.date(from: dateString)
        return date
    }

    func concetenateDateAndTime(date: Date, time:Date ) -> Date? {

        var timeComponents = Calendar.current.dateComponents([.hour, .minute, .second ], from: time)
        var dateComponents =  Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        print(dateComponents.timeZone)
        print(timeComponents.timeZone)
        print( Calendar.current.date(from: dateComponents))

        return Calendar.current.date(from: dateComponents)
    }


//    func todayStartDate() -> String {
//        var date = test()
//        formatter.dateFormat ="
////        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: date!)
////        components.hour = 0
////        components.minute = 0
////        components.second = 0
////        components.timeZone = TimeZone(abbreviation: "UTC")
////        return Calendar.current.date(from: components)
//    }

//    func todaysDate() -> Date? {
//        var date = test()
//        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: date!)
//        components.hour = 23
//        components.minute = 59
//        components.second = 59
//        //components.timeZone = TimeZone(abbreviation: "UTC")
//        return Calendar.current.date(from: components)
//    }


    func shortTimeString(from date:Date) -> String {
        formatter.dateFormat = "h:mm a"
        return formatter.string(from:date)
    }

    func mediumDateString(from date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func fullDateString(from date: Date) -> String {
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func dateStringWithDateTimeStyle(from date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    

}
