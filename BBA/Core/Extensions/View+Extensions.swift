//
//  View+Extensions.swift
//  BBA
//

import SwiftUI

extension View {
    /// 条件修饰器
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 隐藏但不从布局移除
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.opacity(0).allowsHitTesting(false)
        } else {
            self
        }
    }

    /// 圆角矩形边框
    func roundedBorder(_ color: Color = .gray.opacity(0.3), radius: CGFloat = 12, width: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(color, lineWidth: width)
        )
    }
}
