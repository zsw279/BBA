//
//  GrowthView.swift
//  BBA
//
//  成长 Tab - 身高/体重/头围
//

import SwiftUI
import SwiftData
import Charts

struct GrowthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var viewModel: GrowthViewModel?
    @State private var showAddRecord = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel, let baby = babies.first {
                    ScrollView {
                        VStack(spacing: 16) {
                            metricPicker
                            GrowthChartView(viewModel: vm)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            latestStatCard(vm: vm, baby: baby)
                            GrowthRecordList(baby: baby)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("成长")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddRecord = true
                        HapticService.light()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil, let baby = babies.first {
                viewModel = GrowthViewModel(baby: baby)
            }
        }
        .sheet(isPresented: $showAddRecord) {
            if let baby = babies.first {
                AddGrowthRecordView(baby: baby)
            }
        }
    }

    @ViewBuilder
    private var metricPicker: some View {
        if let vm = viewModel {
            Picker("指标", selection: Binding(
                get: { vm.selectedMetric },
                set: { vm.selectedMetric = $0; HapticService.selection() }
            )) {
                ForEach(GrowthMetric.allCases) { metric in
                    Text(metric.displayName).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func latestStatCard(vm: GrowthViewModel, baby: Baby) -> some View {
        if let latest = vm.latestRecord {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("最近记录")
                        .font(.headline)
                    HStack {
                        if let h = latest.heightCm {
                            statColumn(title: "身高", value: UnitConverter.formatHeight(h, unit: baby.preferredHeightUnit), color: .appBlue)
                        }
                        if let w = latest.weightKg {
                            statColumn(title: "体重", value: UnitConverter.formatWeight(w, unit: baby.preferredWeightUnit), color: .appOrange)
                        }
                        if let head = latest.headCircumferenceCm {
                            statColumn(title: "头围", value: UnitConverter.formatHeight(head, unit: baby.preferredHeightUnit), color: .appPurple)
                        }
                    }
                    Text(DateUtils.chineseDate.string(from: latest.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }

    private func statColumn(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.title3.bold()).foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GrowthView()
        .modelContainer(for: Baby.self, inMemory: true)
}
