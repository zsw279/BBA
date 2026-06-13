//
//  SleepListView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct SleepListView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    var body: some View {
        if records.isEmpty {
            EmptyStateView(
                icon: "moon",
                title: "还没有睡眠记录",
                message: "点击右上角 + 添加"
            )
        } else {
            List {
                ForEach(groupedByDay.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text(DateUtils.dateOnly(day))) {
                        ForEach(groupedByDay[day] ?? []) { record in
                            SleepRow(record: record)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        DailyRecordService.shared.deleteSleep(record, in: modelContext)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private var records: [SleepRecord] {
        baby.sleepRecords.sorted { $0.startTime > $1.startTime }
    }

    private var groupedByDay: [Date: [SleepRecord]] {
        Dictionary(grouping: records) { $0.startTime.startOfDay }
    }
}

struct SleepRow: View {
    let record: SleepRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appPurple.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: record.isOngoing ? "moon.zzz.fill" : record.quality.iconName)
                    .foregroundColor(.appPurple)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(durationText)
                        .font(.subheadline.bold())
                    if record.isOngoing {
                        Text("进行中")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.appGreen.opacity(0.2)))
                            .foregroundColor(.appGreen)
                    }
                }
                Text(timeRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var durationText: String {
        if record.isOngoing {
            return "睡中..."
        }
        return record.duration?.durationString ?? "-"
    }

    private var timeRange: String {
        let start = DateUtils.timeOnly.string(from: record.startTime)
        let end = record.endTime.map { DateUtils.timeOnly.string(from: $0) } ?? "现在"
        return "\(start) - \(end)"
    }
}
