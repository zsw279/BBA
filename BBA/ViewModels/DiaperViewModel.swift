//
//  DiaperViewModel.swift
//  BBA
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class DiaperViewModel {
    var baby: Baby
    var time: Date = Date()
    var diaperType: DiaperType = .wet
    var hasRash: Bool = false
    var note: String = ""

    init(baby: Baby) {
        self.baby = baby
    }

    func reset() {
        time = Date()
        diaperType = .wet
        hasRash = false
        note = ""
    }

    func save(in context: ModelContext) {
        DailyRecordService.shared.addDiaper(
            in: context,
            baby: baby,
            time: time,
            diaperType: diaperType,
            note: note.isEmpty ? nil : note,
            hasRash: hasRash
        )
        HapticService.success()
    }
}
