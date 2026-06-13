//
//  ExportViewModel.swift
//  BBA
//
//  导出页专用
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ExportViewModel {
    var baby: Baby
    var selectedMonth: Date = Date()
    var isExporting: Bool = false
    var lastExportURL: URL?
    var errorMessage: String?

    init(baby: Baby) {
        self.baby = baby
    }

    func exportPDF() async {
        isExporting = true
        errorMessage = nil
        defer { isExporting = false }
        do {
            let url = try await ExportService.shared.exportMonthlyPDF(baby: baby, month: selectedMonth)
            lastExportURL = url
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func exportChartImage() {
        isExporting = true
        defer { isExporting = false }
        // 这里只能导出 URL(图片直接在 ImageRenderer 中生成并保存)
        // 简化处理:让用户用 PDF 代替
        errorMessage = "请使用月报 PDF 导出"
    }
}
