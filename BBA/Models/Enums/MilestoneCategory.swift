//
//  MilestoneCategory.swift
//  BBA
//

import Foundation

/// 里程碑分类
enum MilestoneCategory: String, Codable, CaseIterable, Identifiable {
    case motor       // 大运动
    case language    // 语言
    case social      // 社交
    case cognitive   // 认知
    case firstTime   // 第一次

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .motor: return "大运动"
        case .language: return "语言"
        case .social: return "社交"
        case .cognitive: return "认知"
        case .firstTime: return "第一次"
        }
    }

    var iconName: String {
        switch self {
        case .motor: return "figure.run"
        case .language: return "bubble.left.and.bubble.right.fill"
        case .social: return "person.2.fill"
        case .cognitive: return "lightbulb.fill"
        case .firstTime: return "sparkles"
        }
    }

    var colorName: String {
        switch self {
        case .motor: return "blue"
        case .language: return "purple"
        case .social: return "pink"
        case .cognitive: return "orange"
        case .firstTime: return "yellow"
        }
    }
}
