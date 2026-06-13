//
//  StatBadge.swift
//  BBA
//
//  数据徽章 - 用于显示统计数字
//

import SwiftUI

struct StatBadge: View {
    let value: String
    let label: String
    var icon: String? = nil
    var color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    HStack {
        StatBadge(value: "12", label: "今日喂养", icon: "drop.fill", color: .blue)
        StatBadge(value: "8.5h", label: "今日睡眠", icon: "moon.fill", color: .purple)
    }
    .padding()
}
