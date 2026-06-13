//
//  DailyView.swift
//  BBA
//
//  日常 Tab - 子 Tab: 喂养/睡眠/尿布/用药
//

import SwiftUI
import SwiftData

struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var selectedTab: DailyTab = .feeding
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if let baby = babies.first {
                    VStack(spacing: 0) {
                        Picker("", selection: $selectedTab) {
                            ForEach(DailyTab.allCases) { tab in
                                Text(tab.displayName).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        Group {
                            switch selectedTab {
                            case .feeding:
                                FeedingListView(baby: baby)
                            case .sleep:
                                SleepListView(baby: baby)
                            case .diaper:
                                DiaperListView(baby: baby)
                            case .medication:
                                MedicationListView(baby: baby)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("日常")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                        HapticService.light()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            if let baby = babies.first {
                addSheetView(baby: baby)
            }
        }
    }

    @ViewBuilder
    private func addSheetView(baby: Baby) -> some View {
        switch selectedTab {
        case .feeding: AddFeedingView(baby: baby)
        case .sleep: AddSleepView(baby: baby)
        case .diaper: AddDiaperView(baby: baby)
        case .medication: AddMedicationView(baby: baby)
        }
    }
}

enum DailyTab: String, CaseIterable, Identifiable {
    case feeding
    case sleep
    case diaper
    case medication

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .feeding: return "喂养"
        case .sleep: return "睡眠"
        case .diaper: return "尿布"
        case .medication: return "用药"
        }
    }
}

#Preview {
    DailyView()
        .modelContainer(for: Baby.self, inMemory: true)
}
