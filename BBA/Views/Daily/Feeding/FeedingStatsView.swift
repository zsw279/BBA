//
//  FeedingStatsView.swift
//  BBA
//
//  喂养统计 - 7 天 / 30 天
//

import SwiftUI
import SwiftData
import Charts

struct FeedingStatsView: View {
    let baby: Baby
    @State private var rangeDays: Int = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("范围", selection: $rangeDays) {
                Text("7 天").tag(7)
                Text("30 天").tag(30)
            }
            .pickerStyle(.segmented)

            Chart(dailyData) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("次数", item.count)
                )
                .foregroundStyle(.appBlue)
            }
            .frame(height: 200)
        }
    }

    private var dailyData: [FeedingStatItem] {
        let calendar = Calendar.current
        var result: [FeedingStatItem] = []
        for offset in (0..<rangeDays).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let start = day.startOfDay
            let end = day.endOfDay
            let count = baby.feedingRecords.filter { $0.startTime >= start && $0.startTime <= end }.count
            result.append(FeedingStatItem(id: UUID(), date: start, count: count))
        }
        return result
    }
}

struct FeedingStatItem: Identifiable {
    let id: UUID
    let date: Date
    let count: Int
}
