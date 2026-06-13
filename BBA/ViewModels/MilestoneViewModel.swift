//
//  MilestoneViewModel.swift
//  BBA
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class MilestoneViewModel {
    var baby: Baby
    var title: String = ""
    var category: MilestoneCategory = .firstTime
    var achievedDate: Date = Date()
    var notes: String = ""

    init(baby: Baby) {
        self.baby = baby
    }

    func reset() {
        title = ""
        category = .firstTime
        achievedDate = Date()
        notes = ""
    }

    func applyTemplate(_ template: MilestoneTemplate) {
        title = template.title
        category = MilestoneCategory(rawValue: template.category) ?? .firstTime
    }

    func save(in context: ModelContext) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        MilestoneService.shared.addMilestone(
            in: context,
            baby: baby,
            title: title,
            category: category,
            achievedDate: achievedDate,
            notes: notes.isEmpty ? nil : notes
        )
        HapticService.success()
    }
}
