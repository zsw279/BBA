//
//  AddSleepView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddSleepView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var viewModel: SleepViewModel?
    @State private var tickTask: Task<Void, Never>?
    @State private var currentDuration: TimeInterval = 0

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("计时器") {
                            SleepTimerView(
                                duration: currentDuration,
                                isRunning: vm.isTimerRunning,
                                onToggle: { toggleTimer(vm: vm) }
                            )
                        }

                        Section("时间") {
                            DatePicker("开始", selection: Binding(
                                get: { vm.startTime },
                                set: { vm.startTime = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            if !vm.isTimerRunning {
                                DatePicker("结束", selection: Binding(
                                    get: { vm.endTime ?? Date() },
                                    set: { vm.endTime = $0 }
                                ), displayedComponents: [.hourAndMinute])
                            }
                        }

                        Section("质量") {
                            Picker("质量", selection: Binding(
                                get: { vm.quality },
                                set: { vm.quality = $0; HapticService.selection() }
                            )) {
                                ForEach(SleepQuality.allCases) { q in
                                    Label(q.displayName, systemImage: q.iconName).tag(q)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Section("地点") {
                            TextField("如:婴儿床、推车", text: Binding(
                                get: { vm.location },
                                set: { vm.location = $0 }
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
            .navigationTitle("添加睡眠")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        tickTask?.cancel()
                        dismiss()
                    }
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
                viewModel = SleepViewModel(baby: baby)
            }
        }
        .onDisappear {
            tickTask?.cancel()
        }
    }

    private func toggleTimer(vm: SleepViewModel) {
        vm.toggleTimer()
        HapticService.medium()
        if vm.isTimerRunning {
            tickTask = Task {
                while !Task.isCancelled && vm.isTimerRunning {
                    await MainActor.run {
                        currentDuration = vm.currentDuration
                    }
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }
        } else {
            currentDuration = vm.currentDuration
            tickTask?.cancel()
        }
    }

    private func save() {
        guard let vm = viewModel else { return }
        vm.save(in: modelContext)
        dismiss()
    }
}

struct SleepTimerView: View {
    let duration: TimeInterval
    let isRunning: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(duration.clockString)
                .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundColor(isRunning ? .appPurple : .primary)
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                    Text(isRunning ? "结束睡眠" : "开始计时")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(isRunning ? Color.appRed : Color.appPurple)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
