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

    func UTCZeroZeroDateValue(date: Date) -> Date? {

        var components = Calendar.current.dateComponents([.day , .month, .year, .hour, .minute, .second], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "UTC")
        return Calendar.current.date(from: components)
    }

    func tomorrow() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 1

        guard let tomorrow = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }

        return tomorrow
    }

    func test() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 11

        guard let tomorrow = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }

        return tomorrow
    }

  //  -----------------------------------------------

    func shortDate(from dateString: String) -> String {
        formatter.dateFormat = "MMM d, yyyy"
        if dateString.isEmpty != true {
            if let date = formatter.date(from: dateString) {
                return formatter.string(from:date )
            }
        }
        return ""
    }

    func shortDateString(from date: Date) -> String {
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    func fullDateString(from date: Date) -> String {
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    func fullDateStringWithDateStyle(from date: Date) -> String {
        //formatter.dateFormat = "EEEE, MMMM dd, yyyy"//"yyyy-MM-dd hh:mm:ss"
        return formatter.string(from: date)
    }

    func fullDateStringWithDateTimeStyle(from date: Date) -> String {
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func shortTime(from dateString:String) -> String {
        formatter.dateFormat = "h:mm a"
        if dateString.isEmpty != true {
            if let time = formatter.date(from: dateString) {
                return formatter.string(from:time)
            }
        }
        return ""
    }



    func shortTimeString(from date:Date) -> String {
        formatter.dateFormat = "h:mm a"
        return formatter.string(from:date)
    }

    func createShortTimeDate(from timeString:String) -> Date {
        formatter.dateFormat = "h:mm a"
        return formatter.date(from:timeString) ?? Date()
    }

    //FIX-ME: There is a better way to implement below createDate logic. I think we should not return today date if we faile to create a date object from a string.
    func createDate(from dateString:String) -> Date {
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.date(from: dateString) ?? Date()
    }

    func today() -> String {
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: Date())

    }

    func todayLongFormated() -> String {
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formatter.string(from: Date())

    }

    func todayDate() -> Date? {
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.date(from: today())

    }

    func tomorrowString() -> String {
        var components = DateComponents()
        components.day = 1
        guard let tomorrow = Calendar.current.date(byAdding: components, to: Date()) else { return "" }

        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: tomorrow)
    }



    func later() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 2

        guard let laterDate = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }

        return laterDate
    }

    func laterPlusOne() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 3

        guard let laterDate = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }

        return laterDate
    }

//    func dateForCalendar(date: Date, time: Date) -> Date? {
//
//        let currCalendar = Calendar.current
//        var dateComponents = DateComponents()
//        dateComponents.calendar = Calendar.current
//
//        dateComponents.year = currCalendar.component(.year, from: date)
//        dateComponents.month = currCalendar.component(.month, from: date)
//        dateComponents.day = currCalendar.component(.day, from: date)
//        dateComponents.hour = currCalendar.component(.hour, from: time)
//        dateComponents.minute = currCalendar.component(.minute, from: time)
//        dateComponents.second = currCalendar.component(.second, from: time)
//
//        var dateComponents2 = DateComponents()
//        dateComponents.day = 3
//        
//        return dateComponents.date
//        //print("From Calendar.current.date(from: dateComponents)", Calendar.current.date(from: dateComponents) )
//       // print("Calendar.current.date(byAdding: dateComponents, to: createDate(from:today()))", Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) )
//       // return Calendar.current.date(from: dateComponents)
////        guard let tomorrow = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }
//    }
//
//    //2018-02-22 01:00:00 +0000 - hourly
//    //2018-02-24 08:00:00 +0000 - daily
//    //PST to UTC in milatary time, in above format
//    func weatherTime() {
//        
//    }

}
