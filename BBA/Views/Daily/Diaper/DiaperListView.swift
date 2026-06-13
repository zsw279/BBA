//
//  DiaperListView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct DiaperListView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    var body: some View {
        if records.isEmpty {
            EmptyStateView(
                icon: "drop.triangle",
                title: "还没有尿布记录",
                message: "点击右上角 + 添加"
            )
        } else {
            List {
                ForEach(groupedByDay.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text(DateUtils.dateOnly(day))) {
                        ForEach(groupedByDay[day] ?? []) { record in
                            DiaperRow(record: record)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        DailyRecordService.shared.deleteDiaper(record, in: modelContext)
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

    private var records: [DiaperRecord] {
        baby.diaperRecords.sorted { $0.time > $1.time }
    }

    private var groupedByDay: [Date: [DiaperRecord]] {
        Dictionary(grouping: records) { $0.time.startOfDay }
    }
}

struct DiaperRow: View {
    let record: DiaperRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: record.diaperType.iconName)
                    .foregroundColor(Color.fromName(record.diaperType.colorName))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(record.diaperType.displayName)
                    .font(.subheadline.bold())
                if record.hasRash {
                    Label("有红屁屁", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.appRed)
                }
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(DateUtils.timeOnly.string(from: record.time))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
