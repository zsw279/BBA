//
//  DiaperRecord.swift
//  BBA
//

import Foundation
import SwiftData

@Model
final class DiaperRecord {
    @Attribute(.unique) var id: UUID
    var time: Date
    var diaperTypeRaw: String
    var note: String?
    /// 是否有红屁屁
    var hasRash: Bool
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        time: Date = Date(),
        diaperType: DiaperType = .wet,
        note: String? = nil,
        hasRash: Bool = false,
        baby: Baby? = nil
    ) {
        self.id = id
        self.time = time
        self.diaperTypeRaw = diaperType.rawValue
        self.note = note
        self.hasRash = hasRash
        self.baby = baby
        self.createdAt = Date()
    }

    var diaperType: DiaperType {
        get { DiaperType(rawValue: diaperTypeRaw) ?? .wet }
        set { diaperTypeRaw = newValue.rawValue }
    }
}
