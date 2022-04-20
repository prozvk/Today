//
//  ReminderListStyle.swift
//  Today
//
//  Created by MacPro on 14.04.2022.
//

import Foundation

enum ReminderListStyle: Int {
    case today
    case future
    case all
    
    var name: String {
        switch self {
        case .today:
            return NSLocalizedString("Today", comment: "")
        case .future:
            return NSLocalizedString("Future", comment: "")
        case .all:
            return NSLocalizedString("All", comment: "")
        }
    }
    
    func shouldInclude(date: Date) -> Bool {
        let isInToday = Locale.current.calendar.isDateInToday(date)
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date()) && !isInToday
        case .all:
            return true
        }
    }
}
