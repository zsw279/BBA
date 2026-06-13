//
//  AddDiaperView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddDiaperView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var viewModel: DiaperViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("类型") {
                            Picker("类型", selection: Binding(
                                get: { vm.diaperType },
                                set: { vm.diaperType = $0; HapticService.selection() }
                            )) {
                                ForEach(DiaperType.allCases) { type in
                                    Label(type.displayName, systemImage: type.iconName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        Section("时间") {
                            DatePicker("时间", selection: Binding(
                                get: { vm.time },
                                set: { vm.time = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                        }
                        Section("状态") {
                            Toggle("有红屁屁", isOn: Binding(
                                get: { vm.hasRash },
                                set: { vm.hasRash = $0 }
                            ))
                        }
                        Section("备注") {
                            TextField("备注(可选)", text: Binding(
                                get: { vm.note },
                                set: { vm.note = $0 }
                            ), axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("添加尿布")
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
        .onAppear {
            if viewModel == nil {
                viewModel = DiaperViewModel(baby: baby)
            }
        }
    }

    private func save() {
        guard let vm = viewModel else { return }
        vm.save(in: modelContext)
        dismiss()
    }
}
