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
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    func fullDateStringWithDateTimeStyle(from date: Date) -> String {
        formatter.dateStyle = .full
        formatter.timeStyle = .short
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

    func tomorrow() -> String {
        var components = DateComponents()
        components.day = 1
        guard let tomorrow = Calendar.current.date(byAdding: components, to: Date()) else { return "" }

        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: tomorrow)
    }

    func tomorrow() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = 1

        guard let tomorrow = Calendar.current.date(byAdding: dateComponents, to: createDate(from:today())) else { return nil }

        return tomorrow
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

}
