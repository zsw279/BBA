//
//  Milestone.swift
//  BBA
//
//  里程碑 - 宝宝成长中的重要时刻
//

import Foundation
import SwiftData

@Model
final class Milestone {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryRaw: String
    var achievedDate: Date
    var notes: String?
    /// 关联的媒体 ID 列表(JSON 字符串数组)
    var mediaRefsJSON: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        title: String,
        category: MilestoneCategory = .firstTime,
        achievedDate: Date = Date(),
        notes: String? = nil,
        mediaRefs: [UUID] = [],
        baby: Baby? = nil
    ) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.achievedDate = achievedDate
        self.notes = notes
        self.mediaRefsJSON = MediaRefHelper.encode(mediaRefs)
        self.baby = baby
        self.createdAt = Date()
    }

    var category: MilestoneCategory {
        get { MilestoneCategory(rawValue: categoryRaw) ?? .firstTime }
        set { categoryRaw = newValue.rawValue }
    }

    /// 关联的媒体 ID 列表
    var mediaRefs: [UUID] {
        get { MediaRefHelper.decode(mediaRefsJSON) }
        set { mediaRefsJSON = MediaRefHelper.encode(newValue) }
    }

    /// 达成时的月龄
    func ageInMonths() -> Int {
        guard let baby = baby else { return 0 }
        return Calendar.current.dateComponents([.month], from: baby.birthDate, to: achievedDate).month ?? 0
    }
}

/// 媒体 ID 数组 JSON 编解码辅助
enum MediaRefHelper {
    static func encode(_ ids: [UUID]) -> String? {
        guard !ids.isEmpty else { return nil }
        let strings = ids.map { $0.uuidString }
        guard let data = try? JSONEncoder().encode(strings),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }

    static func decode(_ json: String?) -> [UUID] {
        guard let json = json,
              let data = json.data(using: .utf8),
              let strings = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return strings.compactMap { UUID(uuidString: $0) }
    }
}
