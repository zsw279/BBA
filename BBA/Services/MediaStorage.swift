//
//  MediaStorage.swift
//  BBA
//
//  媒体文件存储 - 管理 Documents/Media 和 Thumbnails
//

import Foundation
import UIKit
import AVFoundation
import UniformTypeIdentifiers

enum MediaFolder {
    case media      // 主目录
    case thumbnail  // 缩略图
}

final class MediaStorage {
    static let shared = MediaStorage()

    private let fileManager = FileManager.default

    private init() {
        ensureFolders()
    }

    // MARK: - 目录

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func folder(for type: MediaFolder) -> URL {
        switch type {
        case .media:
            return documentsURL.appendingPathComponent(AppConstants.Folder.media, isDirectory: true)
        case .thumbnail:
            return documentsURL.appendingPathComponent(AppConstants.Folder.thumbnails, isDirectory: true)
        }
    }

    private func ensureFolders() {
        let fm = fileManager
        let urls: [URL] = [
            documentsURL.appendingPathComponent(AppConstants.Folder.photos, isDirectory: true),
            documentsURL.appendingPathComponent(AppConstants.Folder.videos, isDirectory: true),
            documentsURL.appendingPathComponent(AppConstants.Folder.thumbnails, isDirectory: true)
        ]
        for url in urls {
            if !fm.fileExists(atPath: url.path) {
                try? fm.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
    }

    // MARK: - URL

    func mediaURL(for relativeName: String) -> URL? {
        let url = documentsURL.appendingPathComponent(AppConstants.Folder.media, isDirectory: true)
            .appendingPathComponent(relativeName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    func thumbnailURL(for fileName: String) -> URL? {
        let url = folder(for: .thumbnail).appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - 保存

    /// 保存照片
    /// - Returns: 相对路径(以 "Photos/yyyy-MM/UUID.jpg" 形式)
    func saveImage(_ image: UIImage) throws -> (relativePath: String, size: Int64) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "MediaStorage", code: 1, userInfo: [NSLocalizedDescriptionKey: "图片编码失败"])
        }
        let monthFolder = monthString(from: Date())
        let folderURL = documentsURL.appendingPathComponent(AppConstants.Folder.photos, isDirectory: true)
            .appendingPathComponent(monthFolder, isDirectory: true)
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = folderURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        let relativePath = "Photos/\(monthFolder)/\(fileName)"
        return (relativePath, Int64(data.count))
    }

    /// 保存视频(从临时 URL 复制)
    func saveVideo(from sourceURL: URL) throws -> (relativePath: String, size: Int64) {
        let monthFolder = monthString(from: Date())
        let folderURL = documentsURL.appendingPathComponent(AppConstants.Folder.videos, isDirectory: true)
            .appendingPathComponent(monthFolder, isDirectory: true)
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(ext)"
        let destURL = folderURL.appendingPathComponent(fileName)
        try fileManager.copyItem(at: sourceURL, to: destURL)
        let attrs = try fileManager.attributesOfItem(atPath: destURL.path)
        let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
        let relativePath = "Videos/\(monthFolder)/\(fileName)"
        return (relativePath, size)
    }

    /// 保存缩略图
    @discardableResult
    func saveThumbnail(_ image: UIImage, baseID: String = UUID().uuidString) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "MediaStorage", code: 2, userInfo: [NSLocalizedDescriptionKey: "缩略图编码失败"])
        }
        let fileName = "\(baseID).jpg"
        let fileURL = folder(for: .thumbnail).appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return fileName
    }

    /// 从视频 URL 生成缩略图
    func generateThumbnail(for videoURL: URL) async -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let cgImage: CGImage
        do {
            cgImage = try await generator.image(at: CMTime(seconds: 0.5, preferredTimescale: 600)).image
        } catch {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - 删除

    func deleteMedia(fileName: String, in folder: MediaFolder = .media) {
        let url: URL
        if folder == .media {
            url = documentsURL.appendingPathComponent(AppConstants.Folder.media, isDirectory: true)
                .appendingPathComponent(fileName)
        } else {
            url = self.folder(for: .thumbnail).appendingPathComponent(fileName)
        }
        try? fileManager.removeItem(at: url)
    }

    /// 总占用空间(字节)
    func totalStorageSize() -> Int64 {
        let mediaFolder = documentsURL.appendingPathComponent(AppConstants.Folder.media, isDirectory: true)
        let thumbFolder = folder(for: .thumbnail)
        var total: Int64 = 0
        let fm = fileManager
        for folder in [mediaFolder, thumbFolder] {
            if let enumerator = fm.enumerator(at: folder, includingPropertiesForKeys: [.fileSizeKey]) {
                for case let url as URL in enumerator {
                    if let attrs = try? url.resourceValues(forKeys: [.fileSizeKey]),
                       let size = attrs.fileSize {
                        total += Int64(size)
                    }
                }
            }
        }
        return total
    }

    // MARK: - 辅助

    private func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
}
