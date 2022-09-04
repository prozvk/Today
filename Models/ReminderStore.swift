//
//  ReminderStore.swift
//  Today
//
//  Created by MacPro on 17.04.2022.
//

import Foundation
import EventKit

class ReminderStore {
    static let shared = ReminderStore()
    
    private let ekStore = EKEventStore()
    
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    func requestAccess() throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            return
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            ekStore.requestAccess(to: .reminder) { success, error in
                do {
                    guard success else {
                        throw TodayError.accessDenied
                    }
                } catch {}
            }
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
        }
    }
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalendarItem
        }
        return ekReminder
    }
    
    func readAll(completion: @escaping ([Reminder])->()) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        
        let predicate = ekStore.predicateForReminders(in: nil)
//        ekStore.fetchingReminders(matching: predicate) { (ekReminders) in
//            do {
//                let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
//                    do {
//                        return try Reminder(with: ekReminder)
//                    } catch TodayError.reminderHasNoDueDate {
//                        return nil
//                    }
//                }
//                completion(reminders)
//            }
//            catch {
//               print("error in fetching")
//            }
//        }
        ekStore.fetchReminders(matching: predicate) { (ekReminders) in
            guard let reminders = ekReminders else { return }
            
            do {
                let reminders: [Reminder] = try reminders.compactMap { ekReminder in
                    do {
                        return try Reminder(with: ekReminder)
                    } catch TodayError.reminderHasNoDueDate {
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    completion(reminders)
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func remove(with id: Reminder.ID) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder = try read(with: id)
        try ekStore.remove(ekReminder, commit: true)
    }
     
    @discardableResult
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
        }
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
}
