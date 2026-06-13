//
//  ReminderType.swift
//  BBA
//

import Foundation

/// 提醒类型
enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case feeding
    case sleep
    case medication
    case diaper
    case milestone
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .feeding: return "喂养"
        case .sleep: return "睡眠"
        case .medication: return "用药"
        case .diaper: return "尿布"
        case .milestone: return "里程碑"
        case .custom: return "自定义"
        }
    }

    var iconName: String {
        switch self {
        case .feeding: return "drop.fill"
        case .sleep: return "moon.zzz.fill"
        case .medication: return "pills.fill"
        case .diaper: return "drop.triangle.fill"
        case .milestone: return "sparkles"
        case .custom: return "bell.fill"
        }
    }
}
