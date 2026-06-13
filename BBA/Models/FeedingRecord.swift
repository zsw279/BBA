//
//  FeedingRecord.swift
//  BBA
//
//  喂养记录 - 支持母乳(左右分别计时)/ 配方奶 / 辅食 / 水
//

import Foundation
import SwiftData

@Model
final class FeedingRecord {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var feedingTypeRaw: String
    /// 左胸喂养时长(秒)
    var leftBreastDuration: TimeInterval?
    /// 右胸喂养时长(秒)
    var rightBreastDuration: TimeInterval?
    /// 奶量 / 水量(毫升)
    var amountML: Double?
    /// 辅食名称
    var foodName: String?
    var note: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        feedingType: FeedingType = .formula,
        leftBreastDuration: TimeInterval? = nil,
        rightBreastDuration: TimeInterval? = nil,
        amountML: Double? = nil,
        foodName: String? = nil,
        note: String? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.feedingTypeRaw = feedingType.rawValue
        self.leftBreastDuration = leftBreastDuration
        self.rightBreastDuration = rightBreastDuration
        self.amountML = amountML
        self.foodName = foodName
        self.note = note
        self.baby = baby
        self.createdAt = Date()
    }

    var feedingType: FeedingType {
        get { FeedingType(rawValue: feedingTypeRaw) ?? .formula }
        set { feedingTypeRaw = newValue.rawValue }
    }

    /// 总母乳时长(秒)
    var totalBreastDuration: TimeInterval {
        (leftBreastDuration ?? 0) + (rightBreastDuration ?? 0)
    }

    /// 总时长(秒)
    var totalDuration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
}
