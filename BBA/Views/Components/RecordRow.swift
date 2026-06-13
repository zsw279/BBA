//
//  RecordRow.swift
//  BBA
//
//  通用记录行 - 用于列表项
//

import SwiftUI

struct RecordRow<Leading: View, Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var leading: (() -> Leading)? = nil
    var trailing: (() -> Trailing)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let leading = leading {
                leading()
            } else {
                defaultLeadingIcon
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let trailing = trailing {
                trailing()
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            if let onDelete = onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
        }
    }

    private var defaultLeadingIcon: some View {
        Image(systemName: "circle.fill")
            .font(.caption)
            .foregroundColor(.accentColor)
    }
}

#Preview {
    List {
        RecordRow(title: "母乳 左侧", subtitle: "今天 10:30 · 15分钟")
        RecordRow(title: "配方奶", subtitle: "今天 14:00 · 120ml")
        RecordRow(title: "辅食 - 米粉", subtitle: "昨天 18:00")
    }
}
