//
//  ReminderListView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var showAdd = false
    @State private var viewModel: ReminderViewModel?

    var body: some View {
        Group {
            if let baby = babies.first {
                List {
                    if baby.reminders.isEmpty {
                        Section {
                            VStack(spacing: 12) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("还没有提醒")
                                    .font(.headline)
                                Text("为喂养/睡眠/用药设置定时提醒")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        }
                    } else {
                        ForEach(baby.reminders.sorted { $0.scheduledTime < $1.scheduledTime }) { reminder in
                            ReminderRow(reminder: reminder)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task {
                                            await ReminderService.shared.deleteReminder(reminder, in: modelContext)
                                        }
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("提醒")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            if let baby = babies.first {
                AddReminderView(baby: baby, editingReminder: nil)
            }
        }
    }
}

struct ReminderRow: View {
    @Environment(\.modelContext) private var modelContext
    let reminder: Reminder
    @State private var showEdit = false

    var body: some View {
        Button {
            showEdit = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(reminder.reminderType.iconName != "" ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: reminder.reminderType.iconName)
                        .foregroundColor(.accentColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.subheadline.bold())
                    HStack(spacing: 6) {
                        Text(DateUtils.timeOnly.string(from: reminder.scheduledTime))
                            .font(.caption)
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(reminder.repeatInterval.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in
                        Task {
                            await ReminderService.shared.toggleEnabled(reminder, in: modelContext)
                        }
                    }
                ))
                .labelsHidden()
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEdit) {
            if let baby = reminder.baby {
                AddReminderView(baby: baby, editingReminder: reminder)
            }
        }
    }
}
