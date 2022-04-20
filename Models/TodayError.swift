//
//  TodayError.swift
//  Today
//
//  Created by MacPro on 16.04.2022.
//

import Foundation

enum TodayError: LocalizedError {
    case accessDenied
    case accessRestricted
    case failedReadingCalendarItem
    case failedReadingReminders
    case reminderHasNoDueDate
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("App doesn't have access to reminders", comment: "")
        case .accessRestricted:
            return NSLocalizedString("This device doesn't allow access to reminders", comment: "")
        case .failedReadingCalendarItem:
            return NSLocalizedString("Failed to read a calendar item", comment: "")
        case .failedReadingReminders:
            return NSLocalizedString("Failed to read reminders", comment: "")
        case .reminderHasNoDueDate:
            return NSLocalizedString("A reminder has no due date", comment: "")
        case .unknown:
            return NSLocalizedString("Uncnown error", comment: "")
        }
    }
}
