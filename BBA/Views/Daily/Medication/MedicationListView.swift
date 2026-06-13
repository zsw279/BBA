//
//  MedicationListView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    var body: some View {
        if records.isEmpty {
            EmptyStateView(
                icon: "pills",
                title: "还没有用药记录",
                message: "点击右上角 + 添加"
            )
        } else {
            List {
                ForEach(groupedByDay.keys.sorted(by: >), id: \.self) { day in
                    Section(header: Text(DateUtils.dateOnly(day))) {
                        ForEach(groupedByDay[day] ?? []) { record in
                            MedicationRow(record: record)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        DailyRecordService.shared.deleteMedication(record, in: modelContext)
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

    private var records: [MedicationRecord] {
        baby.medicationRecords.sorted { $0.time > $1.time }
    }

    private var groupedByDay: [Date: [MedicationRecord]] {
        Dictionary(grouping: records) { $0.time.startOfDay }
    }
}

struct MedicationRow: View {
    let record: MedicationRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appRed.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "pills.fill")
                    .foregroundColor(.appRed)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .font(.subheadline.bold())
                Text(record.dosage)
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
            Text(DateUtils.timeOnly.string(from: record.time))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
