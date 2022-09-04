//
//  Date+Today.swift
//  Today
//
//  Created by MacPro on 08.04.2022.
//

import Foundation

extension Date {
    var dayAndTimeText: String {
        let time = self
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let timeText = formatter.string(from: time)
        
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            let dateText = formatter.string(from: time)
            let dateAndTimeFormat = NSLocalizedString("%@ at %@", comment: "Date and time format string")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }
    
    var dayText: String {
        if Locale.current.calendar.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today due date description")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            let dateText = formatter.string(from: self)
            return dateText
        }
    }
}
