//
//  MediaService.swift
//  BBA
//
//  媒体(照片/视频)业务服务
//

import Foundation
import SwiftData
import UIKit
import PhotosUI

@MainActor
final class MediaService {
    static let shared = MediaService()

    private init() {}

    // MARK: - 照片

    /// 从 PhotosPickerItem 加载并保存
    @discardableResult
    func savePhoto(
        in context: ModelContext,
        baby: Baby,
        pickerItem: PhotosPickerItem,
        capturedDate: Date = Date(),
        caption: String? = nil
    ) async throws -> MediaItem {
        guard let data = try await pickerItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            throw NSError(domain: "MediaService", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法加载图片"])
        }
        return try await savePhoto(in: context, baby: baby, image: image, capturedDate: capturedDate, caption: caption)
    }

    /// 直接保存 UIImage
    @discardableResult
    func savePhoto(
        in context: ModelContext,
        baby: Baby,
        image: UIImage,
        capturedDate: Date = Date(),
        caption: String? = nil
    ) async throws -> MediaItem {
        let (relativePath, size) = try MediaStorage.shared.saveImage(image)
        let item = MediaItem(
            mediaType: .photo,
            capturedDate: capturedDate,
            fileName: relativePath,
            caption: caption,
            fileSize: size,
            baby: baby
        )
        context.insert(item)
        try? context.save()
        return item
    }

    // MARK: - 视频

    @discardableResult
    func saveVideo(
        in context: ModelContext,
        baby: Baby,
        pickerItem: PhotosPickerItem,
        capturedDate: Date = Date(),
        caption: String? = nil
    ) async throws -> MediaItem {
        guard let movie = try await pickerItem.loadTransferable(type: VideoTransferable.self) else {
            throw NSError(domain: "MediaService", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法加载视频"])
        }
        let (relativePath, size) = try MediaStorage.shared.saveVideo(from: movie.url)
        // 缩略图
        var thumbName: String? = nil
        var duration: Double? = nil
        if let thumb = await MediaStorage.shared.generateThumbnail(for: movie.url) {
            thumbName = try? MediaStorage.shared.saveThumbnail(thumb, baseID: movie.url.deletingPathExtension().lastPathComponent)
        }
        if let dur = try? await movie.url.resourceValues(forKeys: [.durationKey]).duration {
            duration = dur
        }
        let item = MediaItem(
            mediaType: .video,
            capturedDate: capturedDate,
            fileName: relativePath,
            thumbnailFileName: thumbName,
            caption: caption,
            fileSize: size,
            duration: duration,
            baby: baby
        )
        context.insert(item)
        try? context.save()
        return item
    }

    // MARK: - 删除

    func deleteMedia(_ item: MediaItem, in context: ModelContext) {
        MediaStorage.shared.deleteMedia(fileName: item.fileName)
        if let thumb = item.thumbnailFileName {
            MediaStorage.shared.deleteMedia(fileName: thumb, in: .thumbnail)
        }
        context.delete(item)
        try? context.save()
    }

    // MARK: - 查询

    func mediaItems(for baby: Baby) -> [MediaItem] {
        baby.mediaItems.sorted { $0.capturedDate > $1.capturedDate }
    }

    func photos(for baby: Baby) -> [MediaItem] {
        mediaItems(for: baby).filter { $0.mediaType == .photo }
    }

    func videos(for baby: Baby) -> [MediaItem] {
        mediaItems(for: baby).filter { $0.mediaType == .video }
    }
}

// MARK: - Video Transferable

import CoreTransferable
import UniformTypeIdentifiers

struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            // 复制到临时目录
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + "." + received.file.pathExtension)
            try? FileManager.default.copyItem(at: received.file, to: copy)
            return VideoTransferable(url: copy)
        }
    }
}
