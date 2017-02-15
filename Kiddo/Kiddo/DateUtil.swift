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
        formatter.timeZone = TimeZone.current
    }

    func shortDate(from dateString: String) -> String {
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        if dateString.isEmpty != true {
            if let date = formatter.date(from: dateString) {
                return formatter.string(from:date )
            }
        }
        return ""
    }

    func shortTime(from dateString:String) -> String {
        formatter.dateFormat = "HH:mm"
        if dateString.isEmpty != true {
            if let time = formatter.date(from: dateString) {
                return formatter.string(from:time)
            }
        }
        return ""
    }

    func shortDate(from date: Date) -> String {
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }


    func shortTime(from date:Date) -> String {
        formatter.dateFormat = "HH:mm"
        return formatter.string(from:date)
    }

    func createDate(from dateString:String) -> Date {
        formatter.dateFormat = "MM-dd-yyyy"
        print("date:", formatter.date(from: dateString)! as Date)
        return formatter.date(from: dateString) ?? Date()
    }

    func today() -> String {
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: Date())

    }

    func tomorrow() -> String {
        let date = Date()
        var components = DateComponents()
        components.day = 1

        let tomorrow = Calendar.current.date(byAdding: components, to: date)
        formatter.dateFormat = "MM-dd-yyyy"

        return formatter.string(from: tomorrow!)
    }
}
