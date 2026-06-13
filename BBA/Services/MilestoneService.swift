//
//  MilestoneService.swift
//  BBA
//
//  里程碑服务
//

import Foundation
import SwiftData

@MainActor
final class MilestoneService {
    static let shared = MilestoneService()

    private init() {}

    // MARK: - CRUD

    @discardableResult
    func addMilestone(
        in context: ModelContext,
        baby: Baby,
        title: String,
        category: MilestoneCategory,
        achievedDate: Date = Date(),
        notes: String? = nil,
        mediaRefs: [UUID] = []
    ) -> Milestone {
        let milestone = Milestone(
            title: title,
            category: category,
            achievedDate: achievedDate,
            notes: notes,
            mediaRefs: mediaRefs,
            baby: baby
        )
        context.insert(milestone)
        try? context.save()
        return milestone
    }

    func updateMilestone(
        _ milestone: Milestone,
        title: String? = nil,
        category: MilestoneCategory? = nil,
        achievedDate: Date? = nil,
        notes: String?? = nil
    ) {
        if let title = title { milestone.title = title }
        if let category = category { milestone.category = category }
        if let date = achievedDate { milestone.achievedDate = date }
        if let notes = notes { milestone.notes = notes }
    }

    func deleteMilestone(_ milestone: Milestone, in context: ModelContext) {
        context.delete(milestone)
        try? context.save()
    }

    // MARK: - 查询

    /// 按时间倒序返回
    func milestones(for baby: Baby) -> [Milestone] {
        baby.milestones.sorted { $0.achievedDate > $1.achievedDate }
    }

    /// 按类别分组
    func milestonesGrouped(by category: MilestoneCategory, for baby: Baby) -> [Milestone] {
        milestones(for: baby).filter { $0.category == category }
    }
}

/// 预置的里程碑模板
struct MilestoneTemplate: Identifiable, Codable {
    let id: String
    let title: String
    let category: String
    /// 建议达成月龄(0 表示不限制)
    let suggestedMonths: Int
}

enum MilestoneTemplateLoader {
    /// 内置 30+ 预置模板
    static let templates: [MilestoneTemplate] = [
        // 动作
        MilestoneTemplate(id: "t01", title: "第一次抬头", category: "motor", suggestedMonths: 2),
        MilestoneTemplate(id: "t02", title: "第一次翻身", category: "motor", suggestedMonths: 4),
        MilestoneTemplate(id: "t03", title: "会坐", category: "motor", suggestedMonths: 6),
        MilestoneTemplate(id: "t04", title: "开始爬行", category: "motor", suggestedMonths: 8),
        MilestoneTemplate(id: "t05", title: "扶站", category: "motor", suggestedMonths: 9),
        MilestoneTemplate(id: "t06", title: "迈出第一步", category: "motor", suggestedMonths: 12),
        MilestoneTemplate(id: "t07", title: "独立行走", category: "motor", suggestedMonths: 14),

        // 语言
        MilestoneTemplate(id: "t10", title: "第一次笑出声", category: "language", suggestedMonths: 2),
        MilestoneTemplate(id: "t11", title: "咿呀学语", category: "language", suggestedMonths: 4),
        MilestoneTemplate(id: "t12", title: "叫\"妈妈\"", category: "language", suggestedMonths: 10),
        MilestoneTemplate(id: "t13", title: "叫\"爸爸\"", category: "language", suggestedMonths: 11),
        MilestoneTemplate(id: "t14", title: "说第一个单词", category: "language", suggestedMonths: 12),
        MilestoneTemplate(id: "t15", title: "能说短句", category: "language", suggestedMonths: 24),

        // 社交
        MilestoneTemplate(id: "t20", title: "第一次社交微笑", category: "social", suggestedMonths: 2),
        MilestoneTemplate(id: "t21", title: "认生", category: "social", suggestedMonths: 6),
        MilestoneTemplate(id: "t22", title: "挥手再见", category: "social", suggestedMonths: 9),
        MilestoneTemplate(id: "t23", title: "会玩躲猫猫", category: "social", suggestedMonths: 9),
        MilestoneTemplate(id: "t24", title: "和别的小朋友玩", category: "social", suggestedMonths: 18),

        // 认知
        MilestoneTemplate(id: "t30", title: "追视物体", category: "cognitive", suggestedMonths: 2),
        MilestoneTemplate(id: "t31", title: "会抓握玩具", category: "cognitive", suggestedMonths: 4),
        MilestoneTemplate(id: "t32", title: "认生人", category: "cognitive", suggestedMonths: 6),
        MilestoneTemplate(id: "t33", title: "指认物品", category: "cognitive", suggestedMonths: 12),
        MilestoneTemplate(id: "t34", title: "会搭积木", category: "cognitive", suggestedMonths: 18),
        MilestoneTemplate(id: "t35", title: "认识颜色", category: "cognitive", suggestedMonths: 24),

        // 第一次
        MilestoneTemplate(id: "t40", title: "第一次剃胎发", category: "firstTime", suggestedMonths: 1),
        MilestoneTemplate(id: "t41", title: "第一次吃辅食", category: "firstTime", suggestedMonths: 6),
        MilestoneTemplate(id: "t42", title: "第一次发烧", category: "firstTime", suggestedMonths: 0),
        MilestoneTemplate(id: "t43", title: "第一次长牙", category: "firstTime", suggestedMonths: 6),
        MilestoneTemplate(id: "t44", title: "第一次坐飞机/出远门", category: "firstTime", suggestedMonths: 0),
        MilestoneTemplate(id: "t45", title: "第一次看雪", category: "firstTime", suggestedMonths: 0),
        MilestoneTemplate(id: "t46", title: "第一次游泳", category: "firstTime", suggestedMonths: 0),
        MilestoneTemplate(id: "t47", title: "第一次看大海", category: "firstTime", suggestedMonths: 0)
    ]

    /// 按类别分组
    static func grouped() -> [MilestoneCategory: [MilestoneTemplate]] {
        var result: [MilestoneCategory: [MilestoneTemplate]] = [:]
        for t in templates {
            if let cat = MilestoneCategory(rawValue: t.category) {
                result[cat, default: []].append(t)
            }
        }
        return result
    }
}
