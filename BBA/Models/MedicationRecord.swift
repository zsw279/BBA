//
//  MedicationRecord.swift
//  BBA
//

import Foundation
import SwiftData

@Model
final class MedicationRecord {
    @Attribute(.unique) var id: UUID
    var time: Date
    var name: String
    /// 剂量描述,如 "5ml", "半包"
    var dosage: String
    var note: String?
    var createdAt: Date

    @Relationship var baby: Baby?

    init(
        id: UUID = UUID(),
        time: Date = Date(),
        name: String,
        dosage: String,
        note: String? = nil,
        baby: Baby? = nil
    ) {
        self.id = id
        self.time = time
        self.name = name
        self.dosage = dosage
        self.note = note
        self.baby = baby
        self.createdAt = Date()
    }
}
