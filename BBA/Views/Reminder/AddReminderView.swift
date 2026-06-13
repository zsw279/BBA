//
//  AddReminderView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby
    let editingReminder: Reminder?

    @State private var viewModel: ReminderViewModel?
    @State private var scheduledTime: Date

    init(baby: Baby, editingReminder: Reminder?) {
        self.baby = baby
        self.editingReminder = editingReminder
        _scheduledTime = State(initialValue: editingReminder?.scheduledTime ?? Date())
    }

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("标题") {
                            TextField("提醒标题", text: Binding(
                                get: { vm.title },
                                set: { vm.title = $0 }
                            ))
                        }
                        Section("类型") {
                            Picker("类型", selection: Binding(
                                get: { vm.reminderType },
                                set: { vm.reminderType = $0; HapticService.selection() }
                            )) {
                                ForEach(ReminderType.allCases) { type in
                                    Label(type.displayName, systemImage: type.iconName).tag(type)
                                }
                            }
                        }
                        Section("时间") {
                            DatePicker(
                                "提醒时间",
                                selection: Binding(
                                    get: { vm.scheduledTime },
                                    set: { vm.scheduledTime = $0 }
                                ),
                                displayedComponents: [.hourAndMinute]
                            )
                        }
                        Section("重复") {
                            Picker("重复", selection: Binding(
                                get: { vm.repeatInterval },
                                set: { vm.repeatInterval = $0; HapticService.selection() }
                            )) {
                                ForEach(RepeatInterval.allCases) { r in
                                    Text(r.displayName).tag(r)
                                }
                            }
                            if vm.repeatInterval == .custom {
                                WeekdayPicker(selected: Binding(
                                    get: { vm.weekdays },
                                    set: { vm.weekdays = $0 }
                                ))
                            }
                        }
                        Section("备注") {
                            TextField("备注(可选)", text: Binding(
                                get: { vm.note },
                                set: { vm.note = $0 }
                            ), axis: .vertical)
                            .lineLimit(2, reservesSpace: true)
                        }
                        Section {
                            Toggle("启用", isOn: Binding(
                                get: { vm.isEnabled },
                                set: { vm.isEnabled = $0 }
                            ))
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(editingReminder == nil ? "添加提醒" : "编辑提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(viewModel?.title.isEmpty ?? true)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                let vm = ReminderViewModel(baby: baby)
                if let editing = editingReminder {
                    vm.loadFromReminder(editing)
                }
                viewModel = vm
            }
        }
    }

    private func save() {
        guard let vm = viewModel else { return }
        Task {
            await vm.save(in: modelContext)
            dismiss()
        }
    }
}

struct WeekdayPicker: View {
    @Binding var selected: Set<Int>

    private let labels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { day in
                Button {
                    if selected.contains(day) {
                        selected.remove(day)
                    } else {
                        selected.insert(day)
                    }
                    HapticService.selection()
                } label: {
                    Text(labels[day - 1])
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(
                            Circle()
                                .fill(selected.contains(day) ? Color.accentColor : Color.gray.opacity(0.15))
                        )
                        .foregroundColor(selected.contains(day) ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
