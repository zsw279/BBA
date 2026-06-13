//
//  GrowthRecord.swift
//  BBA
//
//  成长记录 - 身高/体重/头围
//  内部统一 cm/kg 存储,UI 层做单位换算
//

import Foundation
import SwiftData

@Model
final class GrowthRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    /// 身高(厘米)
    var heightCm: Double?
    /// 体重(千克)
    var weightKg: Double?
    /// 头围(厘米)
    var headCircumferenceCm: Double?
    var note: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        headCircumferenceCm: Double? = nil,
        note: String? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.date = date
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.headCircumferenceCm = headCircumferenceCm
        self.note = note
        self.baby = baby
        self.createdAt = Date()
    }

    // MARK: - 计算属性

    /// 测量时的月龄(用于图表 X 轴)
    func ageInMonths(reference: Date = Date()) -> Int {
        guard let baby = baby else { return 0 }
        return Calendar.current.dateComponents([.month], from: baby.birthDate, to: date).month ?? 0
    }

    /// 测量时的天数
    func ageInDays(reference: Date = Date()) -> Int {
        guard let baby = baby else { return 0 }
        return Calendar.current.dateComponents([.day], from: baby.birthDate, to: date).day ?? 0
    }
}
