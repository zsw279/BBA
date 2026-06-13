//
//  NotificationService.swift
//  BBA
//
//  本地通知服务
//

import Foundation
import UserNotifications
import SwiftData

@MainActor
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private override init() {
        super.init()
        Task { await refreshAuthStatus() }
    }

    // MARK: - 授权

    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthStatus()
            if granted {
                await registerCategories()
            }
            return granted
        } catch {
            return false
        }
    }

    func refreshAuthStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run { self.authorizationStatus = settings.authorizationStatus }
    }

    /// 注册通知类别(用于交互按钮)
    private func registerCategories() async {
        let markDone = UNNotificationAction(
            identifier: AppConstants.NotificationAction.markDone,
            title: "已完成",
            options: [.foreground]
        )
        let snooze = UNNotificationAction(
            identifier: AppConstants.NotificationAction.snooze,
            title: "10分钟后再提醒",
            options: []
        )

        let categories: [UNNotificationCategory] = [
            UNNotificationCategory(
                identifier: AppConstants.NotificationCategory.feeding,
                actions: [markDone, snooze],
                intentIdentifiers: [],
                options: []
            ),
            UNNotificationCategory(
                identifier: AppConstants.NotificationCategory.medication,
                actions: [markDone, snooze],
                intentIdentifiers: [],
                options: []
            ),
            UNNotificationCategory(
                identifier: AppConstants.NotificationCategory.custom,
                actions: [markDone, snooze],
                intentIdentifiers: [],
                options: []
            )
        ]
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }

    // MARK: - 调度

    /// 调度提醒
    func scheduleReminder(_ reminder: Reminder) async throws {
        cancelReminder(notificationID: reminder.notificationID)
        guard reminder.isEnabled else { return }
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        if let note = reminder.note, !note.isEmpty {
            content.body = note
        } else {
            content.body = "时间到啦!"
        }
        content.sound = .default
        content.userInfo = [
            "reminderID": reminder.id.uuidString,
            "type": reminder.reminderType.rawValue
        ]
        content.categoryIdentifier = categoryID(for: reminder.reminderType)

        let trigger = makeTrigger(for: reminder)
        let request = UNNotificationRequest(
            identifier: reminder.notificationID,
            content: content,
            trigger: trigger
        )
        try await UNUserNotificationCenter.current().add(request)
    }

    /// 取消提醒
    func cancelReminder(notificationID: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    /// 同步所有 Reminder 实体的通知(应用启动时调用)
    func syncAllReminders(in context: ModelContext) async {
        let descriptor = FetchDescriptor<Reminder>(
            predicate: #Predicate { $0.isEnabled }
        )
        guard let reminders = try? context.fetch(descriptor) else { return }
        for reminder in reminders {
            do {
                try await scheduleReminder(reminder)
            } catch {
                print("⚠️ 调度提醒失败: \(error)")
            }
        }
    }

    // MARK: - 触发器

    private func makeTrigger(for reminder: Reminder) -> UNNotificationTrigger? {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: reminder.scheduledTime)

        switch reminder.repeatInterval {
        case .none:
            // 一次性:用具体日期
            var dateComps = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.scheduledTime
            )
            // 如果时间已过,顺延到明天
            if let date = calendar.date(from: dateComps), date < Date() {
                dateComps.day = (dateComps.day ?? 0) + 1
            }
            return UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)

        case .daily:
            return UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        case .weekly:
            var weeklyComps = comps
            weeklyComps.weekday = calendar.component(.weekday, from: reminder.scheduledTime)
            return UNCalendarNotificationTrigger(dateMatching: weeklyComps, repeats: true)

        case .weekdays:
            // 周一到周五每天 - 实际只能一个个加,我们合并为每天
            return UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        case .weekend:
            return UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        case .custom:
            // 自定义(weekdays 数组):以第一个 weekday 为基准
            if let firstDay = reminder.weekdays.sorted().first {
                var customComps = comps
                customComps.weekday = firstDay
                return UNCalendarNotificationTrigger(dateMatching: customComps, repeats: true)
            }
            return UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        }
    }

    // MARK: - 响应处理

    func handleNotificationResponse(response: UNNotificationResponse, userInfo: [NSDictionary]? = [:]) {
        let info = userInfo ?? [:]
        if let reminderID = info["reminderID"] as? String {
            print("🔔 用户点击提醒: \(reminderID)")
        }
        switch response.actionIdentifier {
        case AppConstants.NotificationAction.snooze:
            if let reminderIDStr = info["reminderID"] as? String,
               let reminderID = UUID(uuidString: reminderIDStr) {
                Task {
                    await snoozeReminder(reminderID: reminderID)
                }
            }
        default:
            break
        }
    }

    private func snoozeReminder(reminderID: UUID) async {
        let content = UNMutableNotificationContent()
        content.title = "提醒(10分钟后)"
        content.body = "该处理一下啦"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "snooze-\(reminderID.uuidString)",
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 辅助

    private func categoryID(for type: ReminderType) -> String {
        switch type {
        case .feeding: return AppConstants.NotificationCategory.feeding
        case .sleep: return AppConstants.NotificationCategory.sleep
        case .medication: return AppConstants.NotificationCategory.medication
        case .diaper: return AppConstants.NotificationCategory.diaper
        case .milestone: return AppConstants.NotificationCategory.milestone
        case .custom: return AppConstants.NotificationCategory.custom
        }
    }
}
