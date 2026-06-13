//
//  ReminderViewModel.swift
//  BBA
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReminderViewModel {
    var baby: Baby
    var title: String = ""
    var reminderType: ReminderType = .custom
    var scheduledTime: Date = Date()
    var repeatInterval: RepeatInterval = .none
    var weekdays: Set<Int> = []
    var isEnabled: Bool = true
    var note: String = ""
    var editingReminder: Reminder?

    init(baby: Baby) {
        self.baby = baby
    }

    func loadFromReminder(_ reminder: Reminder) {
        editingReminder = reminder
        title = reminder.title
        reminderType = reminder.reminderType
        scheduledTime = reminder.scheduledTime
        repeatInterval = reminder.repeatInterval
        weekdays = Set(reminder.weekdays)
        isEnabled = reminder.isEnabled
        note = reminder.note ?? ""
    }

    func reset() {
        editingReminder = nil
        title = ""
        reminderType = .custom
        scheduledTime = Date()
        repeatInterval = .none
        weekdays = []
        isEnabled = true
        note = ""
    }

    func save(in context: ModelContext) async {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        do {
            if let editing = editingReminder {
                editing.title = title
                editing.reminderType = reminderType
                editing.scheduledTime = scheduledTime
                editing.repeatInterval = repeatInterval
                editing.weekdays = Array(weekdays).sorted()
                editing.isEnabled = isEnabled
                editing.note = note.isEmpty ? nil : note
                try await ReminderService.shared.updateReminder(editing, in: context)
            } else {
                _ = try await ReminderService.shared.createReminder(
                    in: context,
                    baby: baby,
                    title: title,
                    reminderType: reminderType,
                    scheduledTime: scheduledTime,
                    repeatInterval: repeatInterval,
                    weekdays: Array(weekdays).sorted(),
                    isEnabled: isEnabled,
                    note: note.isEmpty ? nil : note
                )
            }
            HapticService.success()
            reset()
        } catch {
            HapticService.error()
            print("❌ 提醒保存失败: \(error)")
        }
    }
}
