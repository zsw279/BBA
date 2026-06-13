//
//  FeedingType.swift
//  BBA
//

import Foundation

/// 喂养类型
enum FeedingType: String, Codable, CaseIterable, Identifiable {
    case breast       // 母乳
    case formula      // 配方奶
    case solid        // 辅食
    case water        // 水

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breast: return "母乳"
        case .formula: return "配方奶"
        case .solid: return "辅食"
        case .water: return "水"
        }
    }

    var iconName: String {
        switch self {
        case .breast: return "drop.fill"
        case .formula: return "cup.and.saucer.fill"
        case .solid: return "fork.knife"
        case .water: return "drop"
        }
    }
}
