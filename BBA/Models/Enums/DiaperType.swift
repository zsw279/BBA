//
//  DiaperType.swift
//  BBA
//

import Foundation

/// 尿布类型
enum DiaperType: String, Codable, CaseIterable, Identifiable {
    case wet          // 尿
    case dirty        // 大便
    case mixed        // 混合
    case dry          // 干爽(纯更换)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wet: return "小便"
        case .dirty: return "大便"
        case .mixed: return "尿 + 大便"
        case .dry: return "干爽"
        }
    }

    var iconName: String {
        switch self {
        case .wet: return "drop.triangle.fill"
        case .dirty: return "circle.fill"
        case .mixed: return "drop.triangle"
        case .dry: return "checkmark.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .wet: return "yellow"
        case .dirty: return "brown"
        case .mixed: return "orange"
        case .dry: return "green"
        }
    }
}
