//
//  SleepViewModel.swift
//  BBA
//
//  睡眠记录状态
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class SleepViewModel {
    var baby: Baby
    var startTime: Date = Date()
    var endTime: Date?
    var quality: SleepQuality = .normal
    var location: String = ""
    var note: String = ""

    /// 睡眠计时器
    var isTimerRunning: Bool = false
    var timerStart: Date?

    init(baby: Baby) {
        self.baby = baby
    }

    func toggleTimer() {
        if isTimerRunning {
            // 结束睡眠
            isTimerRunning = false
            timerStart = nil
            endTime = Date()
        } else {
            // 开始睡眠
            timerStart = Date()
            startTime = Date()
            endTime = nil
            isTimerRunning = true
        }
    }

    /// 实时已睡时长
    var currentDuration: TimeInterval {
        if isTimerRunning, let start = timerStart {
            return Date().timeIntervalSince(start)
        }
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        }
        return 0
    }

    func reset() {
        startTime = Date()
        endTime = nil
        quality = .normal
        location = ""
        note = ""
        isTimerRunning = false
        timerStart = nil
    }

    func save(in context: ModelContext) {
        DailyRecordService.shared.addSleep(
            in: context,
            baby: baby,
            startTime: startTime,
            endTime: endTime,
            quality: quality,
            location: location.isEmpty ? nil : location,
            note: note.isEmpty ? nil : note
        )
        HapticService.success()
    }
}
