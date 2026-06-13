//
//  RecentActivityList.swift
//  BBA
//
//  最近活动 - 汇总所有记录
//

import SwiftUI
import SwiftData

struct RecentActivityList: View {
    let baby: Baby

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近活动")
                .font(.headline)

            if allRecentItems.isEmpty {
                CardView(background: Color(.secondarySystemGroupedBackground)) {
                    HStack {
                        Image(systemName: "tray")
                            .foregroundColor(.secondary)
                        Text("今天还没有活动")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } else {
                CardView(background: Color(.secondarySystemGroupedBackground), padding: 8) {
                    VStack(spacing: 0) {
                        ForEach(Array(allRecentItems.prefix(10).enumerated()), id: \.element.id) { idx, item in
                            ActivityRow(item: item)
                            if idx < min(allRecentItems.count, 10) - 1 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }
            }
        }
    }

    private var allRecentItems: [ActivityItem] {
        var items: [ActivityItem] = []

        for f in baby.feedingRecords.prefix(20) {
            items.append(ActivityItem.from(feeding: f))
        }
        for s in baby.sleepRecords.prefix(20) {
            items.append(ActivityItem.from(sleep: s))
        }
        for d in baby.diaperRecords.prefix(20) {
            items.append(ActivityItem.from(diaper: d))
        }
        for m in baby.medicationRecords.prefix(20) {
            items.append(ActivityItem.from(medication: m))
        }
        for m in baby.milestones.prefix(20) {
            items.append(ActivityItem.from(milestone: m))
        }

        return items.sorted { $0.date > $1.date }
    }
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let date: Date
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    static func from(feeding: FeedingRecord) -> ActivityItem {
        let detail: String
        switch feeding.feedingType {
        case .breast:
            let left = feeding.leftBreastDuration ?? 0
            let right = feeding.rightBreastDuration ?? 0
            detail = "左 \(Int(left/60))分 · 右 \(Int(right/60))分"
        case .formula, .water:
            detail = "\(Int(feeding.amountML ?? 0))ml"
        case .solid:
            detail = feeding.foodName ?? "辅食"
        }
        return ActivityItem(
            date: feeding.startTime,
            icon: feeding.feedingType.iconName,
            color: .appBlue,
            title: feeding.feedingType.displayName,
            subtitle: "\(detail) · \(DateUtils.smartDateString(feeding.startTime))"
        )
    }

    static func from(sleep: SleepRecord) -> ActivityItem {
        let dur = sleep.duration.map { $0.durationString } ?? "进行中"
        return ActivityItem(
            date: sleep.startTime,
            icon: "moon.fill",
            color: .appPurple,
            title: "睡眠",
            subtitle: "\(dur) · \(DateUtils.smartDateString(sleep.startTime))"
        )
    }

    static func from(diaper: DiaperRecord) -> ActivityItem {
        return ActivityItem(
            date: diaper.time,
            icon: diaper.diaperType.iconName,
            color: .appGreen,
            title: "尿布 · \(diaper.diaperType.displayName)",
            subtitle: DateUtils.smartDateString(diaper.time)
        )
    }

    static func from(medication: MedicationRecord) -> ActivityItem {
        return ActivityItem(
            date: medication.time,
            icon: "pills.fill",
            color: .appRed,
            title: "用药 · \(medication.name)",
            subtitle: "\(medication.dosage) · \(DateUtils.smartDateString(medication.time))"
        )
    }

    static func from(milestone: Milestone) -> ActivityItem {
        return ActivityItem(
            date: milestone.achievedDate,
            icon: "sparkles",
            color: .appOrange,
            title: "里程碑 · \(milestone.title)",
            subtitle: "\(milestone.category.displayName) · \(DateUtils.smartDateString(milestone.achievedDate))"
        )
    }
}

struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: item.icon)
                    .foregroundColor(item.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
}
