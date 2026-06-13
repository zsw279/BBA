//
//  GrowthRecordDetailView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct GrowthRecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let record: GrowthRecord
    let baby: Baby

    @State private var date: Date
    @State private var heightCm: Double
    @State private var weightKg: Double
    @State private var headCircumferenceCm: Double
    @State private var note: String

    init(record: GrowthRecord, baby: Baby) {
        self.record = record
        self.baby = baby
        _date = State(initialValue: record.date)
        _heightCm = State(initialValue: record.heightCm ?? 0)
        _weightKg = State(initialValue: record.weightKg ?? 0)
        _headCircumferenceCm = State(initialValue: record.headCircumferenceCm ?? 0)
        _note = State(initialValue: record.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("日期") {
                    DatePicker("测量日期", selection: $date, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }
                Section("数据") {
                    if record.heightCm != nil {
                        NumberStepper(value: $heightCm, range: 30...150, step: 0.5, unit: "cm", label: "身高")
                    }
                    if record.weightKg != nil {
                        NumberStepper(value: $weightKg, range: 1...50, step: 0.05, unit: "kg", label: "体重", precision: 2)
                    }
                    if record.headCircumferenceCm != nil {
                        NumberStepper(value: $headCircumferenceCm, range: 25...60, step: 0.5, unit: "cm", label: "头围")
                    }
                }
                Section("备注") {
                    TextField("备注", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
                Section {
                    Button(role: .destructive) {
                        GrowthService.shared.deleteRecord(record, in: modelContext)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除记录")
                        }
                    }
                }
            }
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
        }
    }

    private func save() {
        GrowthService.shared.updateRecord(
            record,
            date: date,
            heightCm: .some(record.heightCm != nil ? heightCm : nil),
            weightKg: .some(record.weightKg != nil ? weightKg : nil),
            headCircumferenceCm: .some(record.headCircumferenceCm != nil ? headCircumferenceCm : nil),
            note: .some(note.isEmpty ? nil : note)
        )
        try? modelContext.save()
        dismiss()
    }
}
