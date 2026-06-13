//
//  GrowthChartView.swift
//  BBA
//
//  成长曲线 - 使用 Swift Charts
//

import SwiftUI
import Charts

struct GrowthChartView: View {
    @Bindable var viewModel: GrowthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(viewModel.selectedMetric.displayName)曲线")
                    .font(.subheadline.bold())
                Spacer()
                Text("单位:\(viewModel.selectedMetric.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if viewModel.chartData.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "还没有\(viewModel.selectedMetric.displayName)数据",
                    message: "点击右上角 + 添加第一条记录"
                )
                .frame(height: 220)
            } else {
                Chart(viewModel.chartData) { point in
                    LineMark(
                        x: .value("月龄", point.ageMonths),
                        y: .value(viewModel.selectedMetric.displayName, point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.accent)

                    PointMark(
                        x: .value("月龄", point.ageMonths),
                        y: .value(viewModel.selectedMetric.displayName, point.value)
                    )
                    .foregroundStyle(.accent)
                    .symbolSize(60)
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .stride(by: 2)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let months = value.as(Int.self) {
                                Text("\(months)月")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(String(format: "%.1f", v))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
    }
}
