//
//  AddFeedingView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct AddFeedingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var viewModel: FeedingViewModel?
    @State private var leftTickTask: Task<Void, Never>?
    @State private var rightTickTask: Task<Void, Never>?
    @State private var leftNow: TimeInterval = 0
    @State private var rightNow: TimeInterval = 0

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("喂养类型") {
                            Picker("类型", selection: Binding(
                                get: { vm.feedingType },
                                set: { vm.feedingType = $0; HapticService.selection() }
                            )) {
                                ForEach(FeedingType.allCases) { type in
                                    Label(type.displayName, systemImage: type.iconName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Section("时间") {
                            DatePicker("开始", selection: Binding(
                                get: { vm.startTime },
                                set: { vm.startTime = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            if vm.feedingType != .breast {
                                DatePicker("结束", selection: Binding(
                                    get: { vm.endTime ?? Date() },
                                    set: { vm.endTime = $0 }
                                ), displayedComponents: [.hourAndMinute])
                            }
                        }

                        switch vm.feedingType {
                        case .breast:
                            Section("母乳") {
                                BreastTimerView(
                                    title: "左侧",
                                    icon: "circle.fill",
                                    color: .appPink,
                                    totalDuration: vm.leftDuration,
                                    runningDuration: leftNow,
                                    isRunning: vm.isLeftTimerRunning,
                                    onToggle: { toggleLeftTimer(vm: vm) }
                                )
                                BreastTimerView(
                                    title: "右侧",
                                    icon: "circle.fill",
                                    color: .appBlue,
                                    totalDuration: vm.rightDuration,
                                    runningDuration: rightNow,
                                    isRunning: vm.isRightTimerRunning,
                                    onToggle: { toggleRightTimer(vm: vm) }
                                )
                            }
                        case .formula, .water:
                            Section("奶量 / 水量") {
                                NumberStepper(
                                    value: Binding(
                                        get: { vm.amountML },
                                        set: { vm.amountML = $0 }
                                    ),
                                    range: 0...500,
                                    step: 10,
                                    unit: "ml",
                                    label: "毫升",
                                    precision: 0
                                )
                            }
                        case .solid:
                            Section("辅食") {
                                TextField("食物名称(如:米粉、南瓜泥)", text: Binding(
                                    get: { vm.foodName },
                                    set: { vm.foodName = $0 }
                                ))
                            }
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
            .navigationTitle("添加喂养")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        cancelTimers()
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
                viewModel = FeedingViewModel(baby: baby)
            }
        }
        .onDisappear {
            cancelTimers()
        }
    }

    private func toggleLeftTimer(vm: FeedingViewModel) {
        vm.toggleLeftTimer()
        if vm.isLeftTimerRunning {
            leftTickTask = Task {
                while !Task.isCancelled && vm.isLeftTimerRunning {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if !Task.isCancelled {
                        await MainActor.run {
                            if let start = vm.leftTimerStart {
                                leftNow = Date().timeIntervalSince(start)
                            }
                        }
                    }
                }
            }
        } else {
            leftNow = 0
            leftTickTask?.cancel()
        }
    }

    private func toggleRightTimer(vm: FeedingViewModel) {
        vm.toggleRightTimer()
        if vm.isRightTimerRunning {
            rightTickTask = Task {
                while !Task.isCancelled && vm.isRightTimerRunning {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if !Task.isCancelled {
                        await MainActor.run {
                            if let start = vm.rightTimerStart {
                                rightNow = Date().timeIntervalSince(start)
                            }
                        }
                    }
                }
            }
        } else {
            rightNow = 0
            rightTickTask?.cancel()
        }
    }

    private func cancelTimers() {
        leftTickTask?.cancel()
        rightTickTask?.cancel()
    }

    private func save() {
        guard let vm = viewModel else { return }
        vm.save(in: modelContext)
        dismiss()
    }
}

struct BreastTimerView: View {
    let title: String
    let icon: String
    let color: Color
    let totalDuration: TimeInterval
    let runningDuration: TimeInterval
    let isRunning: Bool
    let onToggle: () -> Void

    private var display: TimeInterval {
        totalDuration + runningDuration
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(display.clockString)
                    .font(.title3.bold().monospacedDigit())
                    .foregroundColor(color)
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundColor(color)
            }
            .buttonStyle(.plain)
        }
    }
}
