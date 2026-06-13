//
//  AddMilestoneView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddMilestoneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby
    let template: MilestoneTemplate?

    @State private var viewModel: MilestoneViewModel?

    init(baby: Baby, template: MilestoneTemplate?) {
        self.baby = baby
        self.template = template
    }

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("标题") {
                            TextField("里程碑名称", text: Binding(
                                get: { vm.title },
                                set: { vm.title = $0 }
                            ))
                        }
                        Section("分类") {
                            Picker("分类", selection: Binding(
                                get: { vm.category },
                                set: { vm.category = $0; HapticService.selection() }
                            )) {
                                ForEach(MilestoneCategory.allCases) { c in
                                    Label(c.displayName, systemImage: c.iconName).tag(c)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Section("日期") {
                            DatePicker("达成日期", selection: Binding(
                                get: { vm.achievedDate },
                                set: { vm.achievedDate = $0 }
                            ), in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                        }
                        Section("备注") {
                            TextField("备注(可选)", text: Binding(
                                get: { vm.notes },
                                set: { vm.notes = $0 }
                            ), axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("添加里程碑")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(viewModel?.title.isEmpty ?? true)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                let vm = MilestoneViewModel(baby: baby)
                if let template = template {
                    vm.applyTemplate(template)
                }
                viewModel = vm
            }
        }
    }

    private func save() {
        guard let vm = viewModel else { return }
        vm.save(in: modelContext)
        dismiss()
    }
}
