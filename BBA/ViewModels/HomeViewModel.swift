//
//  HomeViewModel.swift
//  BBA
//
//  首页状态管理
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    var baby: Baby
    var todayFeedingsCount: Int = 0
    var todaySleepDuration: TimeInterval = 0
    var todayDiaperCount: Int = 0
    var lastFeedingTime: Date?
    var lastSleepStart: Date?
    var lastDiaperTime: Date?

    init(baby: Baby) {
        self.baby = baby
        refresh()
    }

    func refresh() {
        todayFeedingsCount = DailyRecordService.shared.todayFeedings(for: baby).count
        todaySleepDuration = DailyRecordService.shared.todaySleepDuration(for: baby)
        todayDiaperCount = DailyRecordService.shared.todayDiaperCount(for: baby)
        lastFeedingTime = DailyRecordService.shared.lastFeeding(for: baby)?.startTime
        lastSleepStart = DailyRecordService.shared.lastSleep(for: baby)?.startTime
        lastDiaperTime = DailyRecordService.shared.lastDiaper(for: baby)?.time
    }

    /// 距上次喂养的时长
    var timeSinceLastFeeding: TimeInterval? {
        guard let last = lastFeedingTime else { return nil }
        return Date().timeIntervalSince(last)
    }

    /// 距上次尿布的时长
    var timeSinceLastDiaper: TimeInterval? {
        guard let last = lastDiaperTime else { return nil }
        return Date().timeIntervalSince(last)
    }
}
