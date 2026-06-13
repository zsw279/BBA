//
//  FeedingListView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct FeedingListView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    var body: some View {
        if records.isEmpty {
            EmptyStateView(
                icon: "drop",
                title: "还没有喂养记录",
                message: "点击右上角 + 添加第一次记录"
            )
        } else {
            List {
                ForEach(groupedByDay.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text(dayHeader(day))) {
                        ForEach(groupedByDay[day] ?? []) { record in
                            FeedingRow(record: record)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        DailyRecordService.shared.deleteFeeding(record, in: modelContext)
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

    private var records: [FeedingRecord] {
        baby.feedingRecords.sorted { $0.startTime > $1.startTime }
    }

    private var groupedByDay: [Date: [FeedingRecord]] {
        Dictionary(grouping: records) { $0.startTime.startOfDay }
    }

    private func dayHeader(_ date: Date) -> String {
        DateUtils.dateOnly(date)
    }
}

struct FeedingRow: View {
    let record: FeedingRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appBlue.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: record.feedingType.iconName)
                    .foregroundColor(.appBlue)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(record.feedingType.displayName)
                    .font(.subheadline.bold())
                Text(detailText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(DateUtils.timeOnly.string(from: record.startTime))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var detailText: String {
        switch record.feedingType {
        case .breast:
            let leftMin = Int((record.leftBreastDuration ?? 0) / 60)
            let rightMin = Int((record.rightBreastDuration ?? 0) / 60)
            return "左 \(leftMin)分 · 右 \(rightMin)分"
        case .formula, .water:
            return "\(Int(record.amountML ?? 0)) ml"
        case .solid:
            return record.foodName ?? "辅食"
        }
    }
}
