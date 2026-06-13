//
//  FeedingViewModel.swift
//  BBA
//
//  喂养记录状态
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class FeedingViewModel {
    var baby: Baby
    var feedingType: FeedingType = .formula
    var startTime: Date = Date()
    var endTime: Date?
    var leftDuration: TimeInterval = 0
    var rightDuration: TimeInterval = 0
    var amountML: Double = 0
    var foodName: String = ""
    var note: String = ""

    /// 母乳计时器状态
    var isLeftTimerRunning: Bool = false
    var isRightTimerRunning: Bool = false
    var leftTimerStart: Date?
    var rightTimerStart: Date?

    init(baby: Baby) {
        self.baby = baby
    }

    func reset() {
        feedingType = .formula
        startTime = Date()
        endTime = nil
        leftDuration = 0
        rightDuration = 0
        amountML = 0
        foodName = ""
        note = ""
        isLeftTimerRunning = false
        isRightTimerRunning = false
        leftTimerStart = nil
        rightTimerStart = nil
    }

    func toggleLeftTimer() {
        if isLeftTimerRunning {
            if let start = leftTimerStart {
                leftDuration += Date().timeIntervalSince(start)
            }
            isLeftTimerRunning = false
            leftTimerStart = nil
        } else {
            leftTimerStart = Date()
            isLeftTimerRunning = true
        }
    }

    func toggleRightTimer() {
        if isRightTimerRunning {
            if let start = rightTimerStart {
                rightDuration += Date().timeIntervalSince(start)
            }
            isRightTimerRunning = false
            rightTimerStart = nil
        } else {
            rightTimerStart = Date()
            isRightTimerRunning = true
        }
    }

    func save(in context: ModelContext) {
        DailyRecordService.shared.addFeeding(
            in: context,
            baby: baby,
            startTime: startTime,
            endTime: feedingType == .breast ? nil : (endTime ?? Date()),
            feedingType: feedingType,
            leftDuration: feedingType == .breast ? leftDuration : nil,
            rightDuration: feedingType == .breast ? rightDuration : nil,
            amountML: (feedingType == .formula || feedingType == .water) && amountML > 0 ? amountML : nil,
            foodName: feedingType == .solid ? foodName : nil,
            note: note.isEmpty ? nil : note
        )
        HapticService.success()
    }
}
