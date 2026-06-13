//
//  QuickActionGrid.swift
//  BBA
//

import SwiftUI

struct QuickActionGrid: View {
    var onFeeding: () -> Void
    var onDiaper: () -> Void
    var onSleep: () -> Void
    var onGrowth: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷记录")
                .font(.headline)
            HStack(spacing: 12) {
                actionButton(
                    icon: "drop.fill",
                    title: "喂养",
                    color: .appBlue,
                    action: onFeeding
                )
                actionButton(
                    icon: "drop.triangle.fill",
                    title: "尿布",
                    color: .appGreen,
                    action: onDiaper
                )
                actionButton(
                    icon: "moon.fill",
                    title: "睡眠",
                    color: .appPurple,
                    action: onSleep
                )
                actionButton(
                    icon: "ruler",
                    title: "成长",
                    color: .appOrange,
                    action: onGrowth
                )
            }
        }
    }

    @ViewBuilder
    private func actionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticService.light()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
