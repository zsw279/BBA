//
//  AddGrowthRecordView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddGrowthRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var date: Date = Date()
    @State private var heightCm: Double = 0
    @State private var weightKg: Double = 0
    @State private var headCircumferenceCm: Double = 0
    @State private var note: String = ""
    @State private var enableHeight: Bool = true
    @State private var enableWeight: Bool = true
    @State private var enableHead: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("日期") {
                    DatePicker("测量日期", selection: $date, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }

                Section("数据") {
                    Toggle("身高", isOn: $enableHeight)
                    if enableHeight {
                        NumberStepper(
                            value: $heightCm,
                            range: 30...150,
                            step: 0.5,
                            unit: "cm",
                            label: "身高"
                        )
                    }
                    Toggle("体重", isOn: $enableWeight)
                    if enableWeight {
                        NumberStepper(
                            value: $weightKg,
                            range: 1...50,
                            step: 0.05,
                            unit: "kg",
                            label: "体重",
                            precision: 2
                        )
                    }
                    Toggle("头围", isOn: $enableHead)
                    if enableHead {
                        NumberStepper(
                            value: $headCircumferenceCm,
                            range: 25...60,
                            step: 0.5,
                            unit: "cm",
                            label: "头围"
                        )
                    }
                }

                Section("备注") {
                    TextField("备注(可选)", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("添加成长记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                if let latest = GrowthService.shared.latestRecord(for: baby) {
                    heightCm = latest.heightCm ?? heightCm
                    weightKg = latest.weightKg ?? weightKg
                    headCircumferenceCm = latest.headCircumferenceCm ?? headCircumferenceCm
                }
            }
        }
    }

    private var isValid: Bool {
        (enableHeight && heightCm > 0) ||
        (enableWeight && weightKg > 0) ||
        (enableHead && headCircumferenceCm > 0)
    }

    private func save() {
        GrowthService.shared.addRecord(
            in: modelContext,
            baby: baby,
            date: date,
            heightCm: enableHeight ? heightCm : nil,
            weightKg: enableWeight ? weightKg : nil,
            headCircumferenceCm: enableHead ? headCircumferenceCm : nil,
            note: note.isEmpty ? nil : note
        )
        dismiss()
    }
}

#Preview {
    AddGrowthRecordView(baby: Baby(name: "小宝", birthDate: Date(), gender: .boy))
        .modelContainer(for: Baby.self, inMemory: true)
}
