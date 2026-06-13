//
//  MediaType.swift
//  BBA
//

import Foundation

/// 媒体类型
enum MediaType: String, Codable, CaseIterable, Identifiable {
    case photo
    case video

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .photo: return "照片"
        case .video: return "视频"
        }
    }

    var iconName: String {
        switch self {
        case .photo: return "photo"
        case .video: return "video"
        }
    }
}
