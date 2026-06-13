//
//  Baby.swift
//  BBA
//
//  宝宝档案 - 根实体,所有其他记录通过 @Relationship 反向关联到此实体
//

import Foundation
import SwiftData

@Model
final class Baby {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date
    var genderRaw: String
    var bloodType: String?
    /// 头像二进制数据
    @Attribute(.externalStorage) var avatarData: Data?
    var createdAt: Date
    var updatedAt: Date

    /// 单位偏好:"cm" / "inch"
    var preferredHeightUnit: String
    /// 单位偏好:"kg" / "lb"
    var preferredWeightUnit: String

    // 关系(全部级联删除)
    @Relationship(deleteRule: .cascade, inverse: \GrowthRecord.baby)
    var growthRecords: [GrowthRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \FeedingRecord.baby)
    var feedingRecords: [FeedingRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \SleepRecord.baby)
    var sleepRecords: [SleepRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \DiaperRecord.baby)
    var diaperRecords: [DiaperRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \MedicationRecord.baby)
    var medicationRecords: [MedicationRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \Milestone.baby)
    var milestones: [Milestone] = []

    @Relationship(deleteRule: .cascade, inverse: \MediaItem.baby)
    var mediaItems: [MediaItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Reminder.baby)
    var reminders: [Reminder] = []

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        gender: Gender = .other,
        bloodType: String? = nil,
        avatarData: Data? = nil,
        preferredHeightUnit: String = "cm",
        preferredWeightUnit: String = "kg"
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.genderRaw = gender.rawValue
        self.bloodType = bloodType
        self.avatarData = avatarData
        self.preferredHeightUnit = preferredHeightUnit
        self.preferredWeightUnit = preferredWeightUnit
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    // MARK: - 计算属性

    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .other }
        set { genderRaw = newValue.rawValue }
    }

    /// 当前年龄(精确到天)
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }

    /// 月龄
    var ageInMonths: Int {
        ageInDays / 30
    }

    /// 年龄显示文案
    var ageDisplayString: String {
        AgeCalculator.displayString(from: birthDate, to: Date())
    }

    /// 距出生天数
    var daysSinceBirth: Int {
        ageInDays
    }
}
