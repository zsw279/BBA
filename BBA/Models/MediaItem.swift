//
//  MediaItem.swift
//  BBA
//
//  媒体(照片/视频) - SwiftData 只存文件名,文件本身存到沙盒 Documents/Media/
//

import Foundation
import SwiftData
import UIKit

@Model
final class MediaItem {
    @Attribute(.unique) var id: UUID
    var mediaTypeRaw: String
    var capturedDate: Date
    /// 相对文件名(包含子目录),如 "Photos/2024-05/UUID.jpg"
    var fileName: String
    /// 缩略图文件名(视频专用)
    var thumbnailFileName: String?
    var caption: String?
    /// 文件大小(字节)
    var fileSize: Int64
    /// 视频时长(秒)
    var duration: Double?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        mediaType: MediaType,
        capturedDate: Date = Date(),
        fileName: String,
        thumbnailFileName: String? = nil,
        caption: String? = nil,
        fileSize: Int64 = 0,
        duration: Double? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.mediaTypeRaw = mediaType.rawValue
        self.capturedDate = capturedDate
        self.fileName = fileName
        self.thumbnailFileName = thumbnailFileName
        self.caption = caption
        self.fileSize = fileSize
        self.duration = duration
        self.baby = baby
        self.createdAt = Date()
    }

    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .photo }
        set { mediaTypeRaw = newValue.rawValue }
    }

    /// 完整文件 URL
    var fileURL: URL? {
        MediaStorage.shared.mediaURL(for: fileName)
    }

    /// 缩略图 URL
    var thumbnailURL: URL? {
        guard let name = thumbnailFileName else { return fileURL }
        return MediaStorage.shared.thumbnailURL(for: name)
    }
}
