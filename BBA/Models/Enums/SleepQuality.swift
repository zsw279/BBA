//
//  SleepQuality.swift
//  BBA
//

import Foundation

/// 睡眠质量
enum SleepQuality: String, Codable, CaseIterable, Identifiable {
    case good
    case normal
    case poor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .good: return "好"
        case .normal: return "一般"
        case .poor: return "差"
        }
    }

    var iconName: String {
        switch self {
        case .good: return "moon.zzz.fill"
        case .normal: return "moon.fill"
        case .poor: return "moon"
        }
    }
}
