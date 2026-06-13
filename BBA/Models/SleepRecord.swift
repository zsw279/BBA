//
//  SleepRecord.swift
//  BBA
//
//  睡眠记录
//

import Foundation
import SwiftData

@Model
final class SleepRecord {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var qualityRaw: String
    /// 睡眠位置:婴儿床/推车/和大人同床等
    var location: String?
    var note: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        quality: SleepQuality = .normal,
        location: String? = nil,
        note: String? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.qualityRaw = quality.rawValue
        self.location = location
        self.note = note
        self.baby = baby
        self.createdAt = Date()
    }

    var quality: SleepQuality {
        get { SleepQuality(rawValue: qualityRaw) ?? .normal }
        set { qualityRaw = newValue.rawValue }
    }

    /// 睡眠时长(秒)
    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    /// 是否正在睡
    var isOngoing: Bool {
        endTime == nil
    }
}
