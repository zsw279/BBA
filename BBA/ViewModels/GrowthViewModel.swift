//
//  GrowthViewModel.swift
//  BBA
//
//  成长模块状态 - 图表指标切换
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class GrowthViewModel {
    var baby: Baby
    var selectedMetric: GrowthMetric = .height

    init(baby: Baby) {
        self.baby = baby
    }

    var records: [GrowthRecord] {
        GrowthService.shared.recordsForBaby(baby)
    }

    /// 当前指标的图表数据点
    var chartData: [GrowthDataPoint] {
        records.compactMap { record in
            switch selectedMetric {
            case .height:
                guard let v = record.heightCm else { return nil }
                return GrowthDataPoint(ageMonths: record.ageInMonths(), value: v, date: record.date)
            case .weight:
                guard let v = record.weightKg else { return nil }
                return GrowthDataPoint(ageMonths: record.ageInMonths(), value: v, date: record.date)
            case .head:
                guard let v = record.headCircumferenceCm else { return nil }
                return GrowthDataPoint(ageMonths: record.ageInMonths(), value: v, date: record.date)
            }
        }
    }

    /// 最新记录
    var latestRecord: GrowthRecord? {
        GrowthService.shared.latestRecord(for: baby)
    }

    /// 当前指标的最值
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }

    var maxValue: Double {
        chartData.map { $0.value }.max() ?? 0
    }
}

enum GrowthMetric: String, CaseIterable, Identifiable {
    case height
    case weight
    case head

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .height: return "身高"
        case .weight: return "体重"
        case .head: return "头围"
        }
    }

    var unit: String {
        switch self {
        case .height, .head: return "cm"
        case .weight: return "kg"
        }
    }
}

struct GrowthDataPoint: Identifiable {
    let id = UUID()
    let ageMonths: Int
    let value: Double
    let date: Date
}
