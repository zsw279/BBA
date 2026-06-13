//
//  SettingsViewModel.swift
//  BBA
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    var baby: Baby
    var isExporting: Bool = false
    var exportMessage: String?
    var lastExportURL: URL?

    init(baby: Baby) {
        self.baby = baby
    }

    func updateHeightUnit(_ unit: String) {
        baby.preferredHeightUnit = unit
    }

    func updateWeightUnit(_ unit: String) {
        baby.preferredWeightUnit = unit
    }

    func exportMonthlyPDF(month: Date) async {
        isExporting = true
        exportMessage = "正在生成 PDF..."
        defer { isExporting = false }
        do {
            let url = try await ExportService.shared.exportMonthlyPDF(baby: baby, month: month)
            lastExportURL = url
            exportMessage = "已导出:\(url.lastPathComponent)"
            HapticService.success()
        } catch {
            exportMessage = "导出失败:\(error.localizedDescription)"
            HapticService.error()
        }
    }

    func exportJSON() {
        isExporting = true
        exportMessage = "正在备份数据..."
        defer { isExporting = false }
        do {
            let url = try ExportService.shared.exportJSON(baby: baby)
            lastExportURL = url
            exportMessage = "已备份:\(url.lastPathComponent)"
            HapticService.success()
        } catch {
            exportMessage = "备份失败:\(error.localizedDescription)"
            HapticService.error()
        }
    }
}
