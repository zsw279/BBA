//
//  DailyRecordService.swift
//  BBA
//
//  日常记录服务(喂养/睡眠/尿布/用药)
//

import Foundation
import SwiftData

@MainActor
final class DailyRecordService {
    static let shared = DailyRecordService()

    private init() {}

    // MARK: - 喂养

    @discardableResult
    func addFeeding(
        in context: ModelContext,
        baby: Baby,
        startTime: Date,
        endTime: Date? = nil,
        feedingType: FeedingType,
        leftDuration: TimeInterval? = nil,
        rightDuration: TimeInterval? = nil,
        amountML: Double? = nil,
        foodName: String? = nil,
        note: String? = nil
    ) -> FeedingRecord {
        let record = FeedingRecord(
            startTime: startTime,
            endTime: endTime,
            feedingType: feedingType,
            leftBreastDuration: leftDuration,
            rightBreastDuration: rightDuration,
            amountML: amountML,
            foodName: foodName,
            note: note,
            baby: baby
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func deleteFeeding(_ record: FeedingRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    // MARK: - 睡眠

    @discardableResult
    func addSleep(
        in context: ModelContext,
        baby: Baby,
        startTime: Date,
        endTime: Date? = nil,
        quality: SleepQuality = .normal,
        location: String? = nil,
        note: String? = nil
    ) -> SleepRecord {
        let record = SleepRecord(
            startTime: startTime,
            endTime: endTime,
            quality: quality,
            location: location,
            note: note,
            baby: baby
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func endSleep(_ record: SleepRecord, endTime: Date = Date()) {
        record.endTime = endTime
    }

    func deleteSleep(_ record: SleepRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    // MARK: - 尿布

    @discardableResult
    func addDiaper(
        in context: ModelContext,
        baby: Baby,
        time: Date = Date(),
        diaperType: DiaperType = .wet,
        note: String? = nil,
        hasRash: Bool = false
    ) -> DiaperRecord {
        let record = DiaperRecord(
            time: time,
            diaperType: diaperType,
            note: note,
            hasRash: hasRash,
            baby: baby
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func deleteDiaper(_ record: DiaperRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    // MARK: - 用药

    @discardableResult
    func addMedication(
        in context: ModelContext,
        baby: Baby,
        time: Date = Date(),
        name: String,
        dosage: String,
        note: String? = nil
    ) -> MedicationRecord {
        let record = MedicationRecord(
            time: time,
            name: name,
            dosage: dosage,
            note: note,
            baby: baby
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func deleteMedication(_ record: MedicationRecord, in context: ModelContext) {
        context.delete(record)
        try? context.save()
    }

    // MARK: - 统计

    /// 今日喂养次数
    func todayFeedings(for baby: Baby) -> [FeedingRecord] {
        baby.feedingRecords.filter { $0.startTime.isToday }
    }

    /// 今日睡眠总时长(秒)
    func todaySleepDuration(for baby: Baby) -> TimeInterval {
        baby.sleepRecords
            .filter { $0.startTime.isToday }
            .compactMap { $0.duration }
            .reduce(0, +)
    }

    /// 今日尿布次数
    func todayDiaperCount(for baby: Baby) -> Int {
        baby.diaperRecords.filter { $0.time.isToday }.count
    }

    /// 最近一次喂养
    func lastFeeding(for baby: Baby) -> FeedingRecord? {
        baby.feedingRecords.sorted { $0.startTime > $1.startTime }.first
    }

    /// 最近一次睡眠
    func lastSleep(for baby: Baby) -> SleepRecord? {
        baby.sleepRecords.sorted { $0.startTime > $1.startTime }.first
    }

    /// 最近一次尿布
    func lastDiaper(for baby: Baby) -> DiaperRecord? {
        baby.diaperRecords.sorted { $0.time > $1.time }.first
    }
}
