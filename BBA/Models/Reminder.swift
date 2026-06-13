//
//  Reminder.swift
//  BBA
//
//  提醒 - 喂养/睡眠/用药/尿布/自定义,挂载到 UNUserNotificationCenter
//

import Foundation
import SwiftData

@Model
final class Reminder {
    @Attribute(.unique) var id: UUID
    var title: String
    var reminderTypeRaw: String
    var scheduledTime: Date
    var repeatIntervalRaw: String
    /// 周一到周日 1-7(用于自定义重复)
    var weekdaysData: Data?
    var isEnabled: Bool
    /// 对应 UNUserNotificationCenter 的 identifier
    var notificationID: String
    var note: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        title: String,
        reminderType: ReminderType = .custom,
        scheduledTime: Date,
        repeatInterval: RepeatInterval = .none,
        weekdays: [Int] = [],
        isEnabled: Bool = true,
        notificationID: String = UUID().uuidString,
        note: String? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.title = title
        self.reminderTypeRaw = reminderType.rawValue
        self.scheduledTime = scheduledTime
        self.repeatIntervalRaw = repeatInterval.rawValue
        self.weekdaysData = try? JSONEncoder().encode(weekdays)
        self.isEnabled = isEnabled
        self.notificationID = notificationID
        self.note = note
        self.baby = baby
        self.createdAt = Date()
    }

    var reminderType: ReminderType {
        get { ReminderType(rawValue: reminderTypeRaw) ?? .custom }
        set { reminderTypeRaw = newValue.rawValue }
    }

    var repeatInterval: RepeatInterval {
        get { RepeatInterval(rawValue: repeatIntervalRaw) ?? .none }
        set { repeatIntervalRaw = newValue.rawValue }
    }

    var weekdays: [Int] {
        get {
            guard let data = weekdaysData,
                  let arr = try? JSONDecoder().decode([Int].self, from: data) else { return [] }
            return arr
        }
        set {
            weekdaysData = try? JSONEncoder().encode(newValue)
        }
    }
}
