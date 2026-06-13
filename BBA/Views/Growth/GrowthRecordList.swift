//
//  GrowthRecordList.swift
//  BBA
//

import SwiftUI
import SwiftData

struct GrowthRecordList: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("所有记录")
                    .font(.headline)
                Spacer()
                Text("\(baby.growthRecords.count) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if baby.growthRecords.isEmpty {
                CardView(background: Color(.secondarySystemBackground)) {
                    Text("还没有记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else {
                CardView(background: Color(.secondarySystemBackground), padding: 8) {
                    VStack(spacing: 0) {
                        ForEach(records) { record in
                            GrowthRecordRow(record: record, baby: baby)
                            if record.id != records.last?.id {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                }
            }
        }
    }

    private var records: [GrowthRecord] {
        baby.growthRecords.sorted { $0.date > $1.date }
    }
}

struct GrowthRecordRow: View {
    @Environment(\.modelContext) private var modelContext
    let record: GrowthRecord
    let baby: Baby
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DateUtils.chineseDate.string(from: record.date))
                        .font(.subheadline)
                    HStack(spacing: 12) {
                        if let h = record.heightCm {
                            label(icon: "ruler", text: UnitConverter.formatHeight(h, unit: baby.preferredHeightUnit), color: .appBlue)
                        }
                        if let w = record.weightKg {
                            label(icon: "scalemass", text: UnitConverter.formatWeight(w, unit: baby.preferredWeightUnit), color: .appOrange)
                        }
                        if let head = record.headCircumferenceCm {
                            label(icon: "circle.dashed.inset.filled", text: UnitConverter.formatHeight(head, unit: baby.preferredHeightUnit), color: .appPurple)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                GrowthService.shared.deleteRecord(record, in: modelContext)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showDetail) {
            GrowthRecordDetailView(record: record, baby: baby)
        }
    }

    private func label(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
        }
    }
}
