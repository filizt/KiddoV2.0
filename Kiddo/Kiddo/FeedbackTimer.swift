//
//  FeedbackTimer.swift
//  Kiddo
//
//  Created by Mike Miksch on 1/10/18.
//  Copyright © 2018 Filiz Kurban. All rights reserved.
//

import UIKit

class FeedbackTimer: NSObject {
    var startDate : Date?
    var feedbackSubmitted = false
    
    func isTimeToPresent() -> Bool {
        if let startDate = startDate {
            let currentDate = Date()
        }
    }

}
