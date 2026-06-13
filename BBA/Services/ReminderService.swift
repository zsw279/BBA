//
//  ReminderService.swift
//  BBA
//
//  提醒业务服务 - 创建/更新/删除时同步到 NotificationService
//

import Foundation
import SwiftData

@MainActor
final class ReminderService {
    static let shared = ReminderService()

    private init() {}

    // MARK: - CRUD

    @discardableResult
    func createReminder(
        in context: ModelContext,
        baby: Baby,
        title: String,
        reminderType: ReminderType,
        scheduledTime: Date,
        repeatInterval: RepeatInterval = .none,
        weekdays: [Int] = [],
        isEnabled: Bool = true,
        note: String? = nil
    ) async throws -> Reminder {
        let reminder = Reminder(
            title: title,
            reminderType: reminderType,
            scheduledTime: scheduledTime,
            repeatInterval: repeatInterval,
            weekdays: weekdays,
            isEnabled: isEnabled,
            note: note,
            baby: baby
        )
        context.insert(reminder)
        try? context.save()
        if isEnabled {
            try await NotificationService.shared.scheduleReminder(reminder)
        }
        return reminder
    }

    func updateReminder(_ reminder: Reminder, in context: ModelContext) async throws {
        try? context.save()
        // 重新调度
        if reminder.isEnabled {
            try await NotificationService.shared.scheduleReminder(reminder)
        } else {
            NotificationService.shared.cancelReminder(notificationID: reminder.notificationID)
        }
    }

    func toggleEnabled(_ reminder: Reminder, in context: ModelContext) async {
        reminder.isEnabled.toggle()
        try? context.save()
        if reminder.isEnabled {
            try? await NotificationService.shared.scheduleReminder(reminder)
        } else {
            NotificationService.shared.cancelReminder(notificationID: reminder.notificationID)
        }
    }

    func deleteReminder(_ reminder: Reminder, in context: ModelContext) async {
        NotificationService.shared.cancelReminder(notificationID: reminder.notificationID)
        context.delete(reminder)
        try? context.save()
    }

    // MARK: - 查询

    func reminders(for baby: Baby) -> [Reminder] {
        baby.reminders.sorted { $0.scheduledTime < $1.scheduledTime }
    }

    func enabledReminders(for baby: Baby) -> [Reminder] {
        reminders(for: baby).filter { $0.isEnabled }
    }
}
