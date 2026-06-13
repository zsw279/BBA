//
//  Gender.swift
//  BBA
//
//  Created by BBA Team.
//

import Foundation

/// 宝宝性别
enum Gender: String, Codable, CaseIterable, Identifiable {
    case boy
    case girl
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .boy: return "男宝"
        case .girl: return "女宝"
        case .other: return "其他 / 保密"
        }
    }

    var iconName: String {
        switch self {
        case .boy: return "figure.child"
        case .girl: return "figure.child"
        case .other: return "questionmark.circle"
        }
    }
}
