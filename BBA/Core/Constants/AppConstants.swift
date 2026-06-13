//
//  AppConstants.swift
//  BBA
//
//  全局常量
//

import Foundation

enum AppConstants {
    /// 应用名称
    static let appName = "BBA"
    /// 显示名称
    static let displayName = "宝宝成长"

    /// 通知类别 ID
    enum NotificationCategory {
        static let feeding = "BBA_FEEDING"
        static let sleep = "BBA_SLEEP"
        static let medication = "BBA_MEDICATION"
        static let diaper = "BBA_DIAPER"
        static let milestone = "BBA_MILESTONE"
        static let custom = "BBA_CUSTOM"
    }

    /// 通知 Action ID
    enum NotificationAction {
        static let markDone = "BBA_ACTION_DONE"
        static let snooze = "BBA_ACTION_SNOOZE"
    }

    /// UserDefaults Keys
    enum DefaultsKey {
        static let firstLaunch = "BBA.firstLaunch"
        static let preferredHeightUnit = "BBA.heightUnit"
        static let preferredWeightUnit = "BBA.weightUnit"
        static let lastBackupDate = "BBA.lastBackupDate"
    }

    /// 文件夹名
    enum Folder {
        static let media = "Media"
        static let photos = "Media/Photos"
        static let videos = "Media/Videos"
        static let thumbnails = "Thumbnails"
        static let exports = "Exports"
    }
}
