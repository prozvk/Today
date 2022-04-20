//
//  EKEventStore+AsyncFetch.swift
//  Today
//
//  Created by MacPro on 16.04.2022.
//

import Foundation
import EventKit

extension EKEventStore {
    
    func fetchingReminders(matching predicate: NSPredicate, completion: @escaping ([EKReminder])->()) {
        fetchReminders(matching: predicate) { (reminders) in
            guard let reminders = reminders else { return }
            completion(reminders)
            
            do {
                let reminders: [Reminder] = try reminders.compactMap { ekReminder in
                    do {
                        return try Reminder(with: ekReminder)
                    } catch TodayError.reminderHasNoDueDate {
                        return nil
                    }
                }
                //completion(reminders)
            }
            catch {
               print("error in fetching")
            }
        }
    }
}
