//
//  MilestoneView.swift
//  BBA
//
//  里程碑 Tab
//

import SwiftUI
import SwiftData

struct MilestoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var showAdd = false
    @State private var showTemplate = false

    var body: some View {
        NavigationStack {
            Group {
                if let baby = babies.first {
                    Group {
                        if baby.milestones.isEmpty {
                            EmptyStateView(
                                icon: "sparkles",
                                title: "还没有里程碑",
                                message: "记录宝宝的每一个第一次",
                                actionTitle: "从模板选择",
                                action: { showTemplate = true }
                            )
                        } else {
                            MilestoneTimelineView(milestones: MilestoneService.shared.milestones(for: baby))
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("里程碑")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showTemplate = true
                        } label: {
                            Label("从模板选择", systemImage: "list.bullet.rectangle")
                        }
                        Button {
                            showAdd = true
                        } label: {
                            Label("自定义", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            if let baby = babies.first {
                AddMilestoneView(baby: baby, template: nil)
            }
        }
        .sheet(isPresented: $showTemplate) {
            if let baby = babies.first {
                MilestoneTemplatePicker(baby: baby)
            }
        }
    }
}

#Preview {
    MilestoneView()
        .modelContainer(for: Baby.self, inMemory: true)
}
