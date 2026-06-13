//
//  ModelContainer+Shared.swift
//  BBA
//
//  共享的 SwiftData ModelContainer
//

import Foundation
import SwiftData

/// 共享 ModelContainer
enum SharedModelContainer {
    static let shared = SharedModelContainerImpl()
}

final class SharedModelContainerImpl {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Baby.self,
            GrowthRecord.self,
            FeedingRecord.self,
            SleepRecord.self,
            DiaperRecord.self,
            MedicationRecord.self,
            Milestone.self,
            MediaItem.self,
            Reminder.self
        ])
        let configuration = ModelConfiguration(
            "BBAStore",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        do {
            self.container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // 极端情况:用内存模式兜底
            let fallbackConfig = ModelConfiguration(
                "BBAMemory",
                schema: schema,
                isStoredInMemoryOnly: true
            )
            self.container = try! ModelContainer(for: schema, configurations: [fallbackConfig])
            print("⚠️ SwiftData 持久化失败,已切换为内存模式: \(error)")
        }
    }
}
