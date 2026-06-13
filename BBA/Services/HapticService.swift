//
//  HapticService.swift
//  BBA
//
//  触觉反馈封装
//

import UIKit

enum HapticService {
    /// 轻微点击
    static func light() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred()
    }

    /// 中等强度
    static func medium() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.impactOccurred()
    }

    /// 重击
    static func heavy() {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.impactOccurred()
    }

    /// 成功反馈
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }

    /// 警告
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.warning)
    }

    /// 错误
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.error)
    }

    /// 选择变化
    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.selectionChanged()
    }
}
