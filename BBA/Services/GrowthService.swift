//
//  GrowthService.swift
//  BBA
//
//  成长记录服务
//

import Foundation
import SwiftData

@MainActor
final class GrowthService {
    static let shared = GrowthService()

    private init() {}

    // MARK: - CRUD

    @discardableResult
    func addRecord(
        in context: ModelContext,
        baby: Baby,
        date: Date,
        heightCm: Double?,
        weightKg: Double?,
        headCircumferenceCm: Double? = nil,
        note: String? = nil
    ) -> GrowthRecord {
        let record = GrowthRecord(
            date: date,
            heightCm: heightCm,
            weightKg: weightKg,
            headCircumferenceCm: headCircumferenceCm,
            note: note,
            baby: baby
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func updateRecord(
        _ record: GrowthRecord,
        date: Date? = nil,
        heightCm: Double?? = nil,
        weightKg: Double?? = nil,
        headCircumferenceCm: Double?? = nil,
        note: String?? = nil
    ) {
        if let date = date { record.date = date }
        if let heightCm = heightCm { record.heightCm = heightCm }
        if let weightKg = weightKg { record.weightKg = weightKg }
        if let head = headCircumferenceCm { record.headCircumferenceCm = head }
        if let note = note { record.note = note }
    }

    func deleteRecord(_ record: GrowthRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    // MARK: - 查询

    /// 按月龄升序返回所有记录
    func recordsForBaby(_ baby: Baby) -> [GrowthRecord] {
        baby.growthRecords.sorted { $0.date < $1.date }
    }

    /// 最新一条记录
    func latestRecord(for baby: Baby) -> GrowthRecord? {
        baby.growthRecords.sorted { $0.date > $1.date }.first
    }

    /// 某月龄区间的记录
    func records(for baby: Baby, in monthsRange: ClosedRange<Int>) -> [GrowthRecord] {
        recordsForBaby(baby).filter {
            let m = $0.ageInMonths()
            return monthsRange.contains(m)
        }
    }
}
