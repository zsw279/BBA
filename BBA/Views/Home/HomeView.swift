//
//  HomeView.swift
//  BBA
//
//  首页 - 今日摘要 + 快捷记录 + 最近活动
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var viewModel: HomeViewModel?
    @State private var showAddFeeding = false
    @State private var showAddDiaper = false
    @State private var showAddSleep = false
    @State private var showAddGrowth = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel, let baby = babies.first {
                    ScrollView {
                        VStack(spacing: 16) {
                            babyHeader(baby: baby)
                            TodaySummaryCard(viewModel: vm)
                                .padding(.horizontal)
                            QuickActionGrid(
                                onFeeding: { showAddFeeding = true },
                                onDiaper: { showAddDiaper = true },
                                onSleep: { showAddSleep = true },
                                onGrowth: { showAddGrowth = true }
                            )
                            .padding(.horizontal)
                            RecentActivityList(baby: baby)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                    .refreshable {
                        vm.refresh()
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("首页")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if viewModel == nil, let baby = babies.first {
                viewModel = HomeViewModel(baby: baby)
            }
        }
        .sheet(isPresented: $showAddFeeding, onDismiss: { viewModel?.refresh() }) {
            if let baby = babies.first {
                AddFeedingView(baby: baby)
            }
        }
        .sheet(isPresented: $showAddDiaper, onDismiss: { viewModel?.refresh() }) {
            if let baby = babies.first {
                AddDiaperView(baby: baby)
            }
        }
        .sheet(isPresented: $showAddSleep, onDismiss: { viewModel?.refresh() }) {
            if let baby = babies.first {
                AddSleepView(baby: baby)
            }
        }
        .sheet(isPresented: $showAddGrowth, onDismiss: { viewModel?.refresh() }) {
            if let baby = babies.first {
                AddGrowthRecordView(baby: baby)
            }
        }
    }

    @ViewBuilder
    private func babyHeader(baby: Baby) -> some View {
        HStack(spacing: 12) {
            Group {
                if let data = baby.avatarData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(Color.appPink.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.appPink)
                        )
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(baby.name)
                    .font(.title2.bold())
                Text(baby.ageDisplayString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Baby.self, inMemory: true)
}
