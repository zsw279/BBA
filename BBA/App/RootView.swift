//
//  RootView.swift
//  BBA
//
//  根视图 - 决定显示 Onboarding 还是主 TabView
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]

    var body: some View {
        Group {
            if babies.isEmpty {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: babies.isEmpty)
    }
}

/// 5 个主 Tab
struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(MainTab.home)

            GrowthView()
                .tabItem {
                    Label("成长", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(MainTab.growth)

            DailyView()
                .tabItem {
                    Label("日常", systemImage: "list.bullet.rectangle")
                }
                .tag(MainTab.daily)

            MilestoneView()
                .tabItem {
                    Label("里程碑", systemImage: "sparkles")
                }
                .tag(MainTab.milestone)

            SettingsView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
                .tag(MainTab.settings)
        }
        .tint(.accentColor)
    }
}

enum MainTab: Hashable {
    case home
    case growth
    case daily
    case milestone
    case settings
}

#Preview {
    RootView()
        .modelContainer(for: Baby.self, inMemory: true)
}
