//
//  AddMedicationView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var time: Date = Date()
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("药物") {
                    TextField("药物名称(如:泰诺林)", text: $name)
                    TextField("剂量(如:5ml, 半包)", text: $dosage)
                }
                Section("时间") {
                    DatePicker("用药时间", selection: $time, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }
                Section("备注") {
                    TextField("备注(可选)", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("添加用药")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }

    private func save() {
        DailyRecordService.shared.addMedication(
            in: modelContext,
            baby: baby,
            time: time,
            name: name,
            dosage: dosage,
            note: note.isEmpty ? nil : note
        )
        dismiss()
    }
}
