//
//  TodaySummaryCard.swift
//  BBA
//

import SwiftUI

struct TodaySummaryCard: View {
    let viewModel: HomeViewModel

    var body: some View {
        CardView(background: Color(.secondarySystemGroupedBackground)) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("今天")
                        .font(.headline)
                    Spacer()
                    Text(DateUtils.chineseDate.string(from: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    StatBadge(
                        value: "\(viewModel.todayFeedingsCount)",
                        label: "次喂养",
                        icon: "drop.fill",
                        color: .appBlue
                    )
                    StatBadge(
                        value: durationString(viewModel.todaySleepDuration),
                        label: "睡眠",
                        icon: "moon.zzz.fill",
                        color: .appPurple
                    )
                    StatBadge(
                        value: "\(viewModel.todayDiaperCount)",
                        label: "换尿布",
                        icon: "drop.triangle.fill",
                        color: .appGreen
                    )
                }

                Divider()

                VStack(spacing: 8) {
                    if let last = viewModel.lastFeedingTime {
                        summaryRow(icon: "drop.fill", color: .appBlue, label: "上次喂养", value: DateUtils.smartDateString(last))
                    }
                    if let last = viewModel.lastSleepStart {
                        summaryRow(icon: "moon.fill", color: .appPurple, label: "上次睡眠", value: DateUtils.smartDateString(last))
                    }
                    if let last = viewModel.lastDiaperTime {
                        summaryRow(icon: "drop.triangle.fill", color: .appGreen, label: "上次尿布", value: DateUtils.smartDateString(last))
                    }
                    if viewModel.lastFeedingTime == nil && viewModel.lastSleepStart == nil && viewModel.lastDiaperTime == nil {
                        Text("今天还没有记录,点击下方按钮开始吧 👇")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private func summaryRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(label).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline).foregroundColor(.secondary)
        }
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        }
        return "0m"
    }
}
