//
//  CardView.swift
//  BBA
//
//  通用卡片容器
//

import SwiftUI

struct CardView<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var background: Color = Color(.secondarySystemBackground)
    var content: () -> Content

    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        background: Color = Color(.secondarySystemBackground),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.background = background
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        CardView {
            Text("Hello Card")
        }
        CardView(background: .blue.opacity(0.1)) {
            VStack(alignment: .leading) {
                Text("彩色卡片").font(.headline)
                Text("内容")
            }
        }
    }
    .padding()
}
