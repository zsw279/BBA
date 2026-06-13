//
//  MilestoneTimelineView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct MilestoneTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    let milestones: [Milestone]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(milestones) { milestone in
                    TimelineRow(milestone: milestone)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                MilestoneService.shared.deleteMilestone(milestone, in: modelContext)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct TimelineRow: View {
    let milestone: Milestone

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.fromName(milestone.category.colorName).opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: milestone.category.iconName)
                        .foregroundColor(Color.fromName(milestone.category.colorName))
                }
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 44)

            CardView(background: Color(.secondarySystemGroupedBackground)) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(milestone.title)
                            .font(.subheadline.bold())
                        Spacer()
                        Text(milestone.category.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.fromName(milestone.category.colorName).opacity(0.15))
                            )
                            .foregroundColor(Color.fromName(milestone.category.colorName))
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(DateUtils.chineseDate.string(from: milestone.achievedDate))
                            .font(.caption)
                        Text("·")
                            .foregroundColor(.secondary)
                        Text("\(milestone.ageInMonths())月龄")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    if let notes = milestone.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
        }
    }
}
