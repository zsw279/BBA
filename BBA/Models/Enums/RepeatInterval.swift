//
//  RepeatInterval.swift
//  BBA
//

import Foundation

/// 重复间隔
enum RepeatInterval: String, Codable, CaseIterable, Identifiable {
    case none        // 一次性
    case daily       // 每天
    case weekly      // 每周
    case weekdays    // 工作日(周一到周五)
    case weekend     // 周末
    case custom      // 自定义(weekdays 数组决定)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "仅一次"
        case .daily: return "每天"
        case .weekly: return "每周"
        case .weekdays: return "工作日"
        case .weekend: return "周末"
        case .custom: return "自定义"
        }
    }
}
