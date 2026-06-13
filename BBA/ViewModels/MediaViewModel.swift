//
//  MediaViewModel.swift
//  BBA
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI

@MainActor
@Observable
final class MediaViewModel {
    var baby: Baby
    var photoItems: [PhotosPickerItem] = []
    var videoItems: [PhotosPickerItem] = []
    var isUploading: Bool = false
    var uploadProgress: String = ""
    var displayMode: MediaDisplayMode = .grid

    init(baby: Baby) {
        self.baby = baby
    }

    func handlePickedPhotos(in context: ModelContext) async {
        guard !photoItems.isEmpty else { return }
        isUploading = true
        let total = photoItems.count
        uploadProgress = "准备上传 0/\(total)"
        var saved: [MediaItem] = []
        for (idx, item) in photoItems.enumerated() {
            do {
                uploadProgress = "上传中 \(idx + 1)/\(total)"
                let media = try await MediaService.shared.savePhoto(in: context, baby: baby, pickerItem: item)
                saved.append(media)
            } catch {
                print("❌ 照片保存失败: \(error)")
            }
        }
        isUploading = false
        uploadProgress = ""
        photoItems = []
        if !saved.isEmpty {
            HapticService.success()
        }
    }

    func handlePickedVideos(in context: ModelContext) async {
        guard !videoItems.isEmpty else { return }
        isUploading = true
        let total = videoItems.count
        uploadProgress = "准备上传 0/\(total)"
        for (idx, item) in videoItems.enumerated() {
            do {
                uploadProgress = "上传中 \(idx + 1)/\(total)"
                _ = try await MediaService.shared.saveVideo(in: context, baby: baby, pickerItem: item)
            } catch {
                print("❌ 视频保存失败: \(error)")
            }
        }
        isUploading = false
        uploadProgress = ""
        videoItems = []
        HapticService.success()
    }
}

enum MediaDisplayMode: String, CaseIterable, Identifiable {
    case grid
    case timeline

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grid: return "网格"
        case .timeline: return "时间线"
        }
    }

    var iconName: String {
        switch self {
        case .grid: return "square.grid.3x3"
        case .timeline: return "list.bullet"
        }
    }
}
