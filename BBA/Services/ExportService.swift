//
//  ExportService.swift
//  BBA
//
//  PDF / 图片导出
//

import Foundation
import UIKit
import SwiftUI
import PDFKit
import SwiftData

@MainActor
final class ExportService {
    static let shared = ExportService()

    private init() {}

    // MARK: - PDF

    /// 导出宝宝成长月报为 PDF
    /// - Parameters:
    ///   - baby: 宝宝实体
    ///   - month: 月份(取月份第一天作为开始)
    /// - Returns: PDF 文件 URL
    func exportMonthlyPDF(baby: Baby, month: Date) async throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let url = exportFolderURL().appendingPathComponent("BBA-\(baby.name)-\(monthString(from: month)).pdf")

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            drawPDFPage(
                ctx: ctx,
                baby: baby,
                month: month,
                pageBounds: pageBounds
            )

            // 多页
            let morePages = calculateExtraPages(for: baby, month: month)
            for _ in 0..<morePages {
                ctx.beginPage()
                drawPDFPage(
                    ctx: ctx,
                    baby: baby,
                    month: month,
                    pageBounds: pageBounds,
                    continuation: true
                )
            }
        }
        try data.write(to: url, options: .atomic)
        return url
    }

    private func drawPDFPage(
        ctx: UIGraphicsPDFRendererContext,
        baby: Baby,
        month: Date,
        pageBounds: CGRect,
        continuation: Bool = false
    ) {
        let margin: CGFloat = 40
        var y: CGFloat = margin

        // 标题
        let title = "宝宝成长月报"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttrs)
        titleString.draw(at: CGPoint(x: margin, y: y))
        y += 36

        // 宝宝信息
        let subtitle = "\(baby.name) · \(DateUtils.chineseDate.string(from: month))"
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        NSAttributedString(string: subtitle, attributes: subAttrs).draw(at: CGPoint(x: margin, y: y))
        y += 30

        // 宝宝基本信息卡片
        let infoText = """
        出生日期: \(DateUtils.chineseDate.string(from: baby.birthDate))
        当前月龄: \(baby.ageDisplayString)
        性别: \(baby.gender.displayName)
        """
        let infoAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        NSAttributedString(string: infoText, attributes: infoAttrs).draw(in: CGRect(x: margin, y: y, width: pageBounds.width - margin * 2, height: 80))
        y += 90

        // 分隔线
        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y))
        line.addLine(to: CGPoint(x: pageBounds.width - margin, y: y))
        UIColor.separator.setStroke()
        line.lineWidth = 0.5
        line.stroke()
        y += 16

        // 本月数据统计
        let monthRecords = recordsInMonth(baby: baby, month: month)
        let summary = """
        本月喂养次数: \(monthRecords.feedings.count)
        本月睡眠次数: \(monthRecords.sleeps.count)
        本月尿布次数: \(monthRecords.diapers.count)
        本月里程碑: \(monthRecords.milestones.count)
        本月照片/视频: \(monthRecords.media.count)
        """
        let sumAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        NSAttributedString(string: summary, attributes: sumAttrs).draw(in: CGRect(x: margin, y: y, width: pageBounds.width - margin * 2, height: 120))
        y += 130

        // 里程碑列表
        if !monthRecords.milestones.isEmpty {
            let sectionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            NSAttributedString(string: "本月里程碑", attributes: sectionAttrs).draw(at: CGPoint(x: margin, y: y))
            y += 24

            for milestone in monthRecords.milestones.prefix(8) {
                let line = "• \(milestone.title)(\(milestone.category.displayName)) - \(DateUtils.chineseDate.string(from: milestone.achievedDate))"
                let lineAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
                NSAttributedString(string: line, attributes: lineAttrs).draw(at: CGPoint(x: margin + 8, y: y))
                y += 18
            }
            y += 8
        }

        // 成长记录
        if !monthRecords.growths.isEmpty {
            let sectionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            NSAttributedString(string: "本月成长记录", attributes: sectionAttrs).draw(at: CGPoint(x: margin, y: y))
            y += 24

            for g in monthRecords.growths.prefix(6) {
                var line = "• \(DateUtils.chineseDate.string(from: g.date))"
                if let h = g.heightCm { line += " 身高 \(String(format: "%.1f", h))cm" }
                if let w = g.weightKg { line += " 体重 \(String(format: "%.2f", w))kg" }
                let lineAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
                NSAttributedString(string: line, attributes: lineAttrs).draw(at: CGPoint(x: margin + 8, y: y))
                y += 18
            }
            y += 8
        }

        // 页脚
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        let footer = "由 BBA 宝宝成长 APP 生成 · \(DateUtils.dateTime.string(from: Date()))"
        NSAttributedString(string: footer, attributes: footerAttrs).draw(
            at: CGPoint(x: margin, y: pageBounds.height - margin / 2)
        )
    }

    // MARK: - 图片导出

    /// 导出成长曲线为 UIImage(用户在分享面板选)
    @MainActor
    func exportGrowthChartImage(baby: Baby, size: CGSize = CGSize(width: 800, height: 600)) -> UIImage? {
        let chartView = GrowthChartExportView(baby: baby)
            .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: chartView)
        renderer.scale = 2.0
        return renderer.uiImage
    }

    /// 导出所有数据为 JSON(备份)
    func exportJSON(baby: Baby) throws -> URL {
        struct Backup: Codable {
            let exportDate: Date
            let baby: BabyBackup
            let growths: [GrowthRecord]
            let feedings: [FeedingRecord]
            let sleeps: [SleepRecord]
            let diapers: [DiaperRecord]
            let medications: [MedicationRecord]
            let milestones: [Milestone]
            let mediaMetadata: [MediaMeta]
            let reminders: [Reminder]
        }
        struct BabyBackup: Codable {
            let name: String
            let birthDate: Date
            let gender: String
            let bloodType: String?
        }
        struct MediaMeta: Codable {
            let id: UUID
            let mediaType: String
            let capturedDate: Date
            let fileName: String
            let caption: String?
        }
        let backup = Backup(
            exportDate: Date(),
            baby: BabyBackup(
                name: baby.name,
                birthDate: baby.birthDate,
                gender: baby.gender.rawValue,
                bloodType: baby.bloodType
            ),
            growths: baby.growthRecords,
            feedings: baby.feedingRecords,
            sleeps: baby.sleepRecords,
            diapers: baby.diaperRecords,
            medications: baby.medicationRecords,
            milestones: baby.milestones,
            mediaMetadata: baby.mediaItems.map {
                MediaMeta(
                    id: $0.id,
                    mediaType: $0.mediaTypeRaw,
                    capturedDate: $0.capturedDate,
                    fileName: $0.fileName,
                    caption: $0.caption
                )
            },
            reminders: baby.reminders
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backup)
        let url = exportFolderURL().appendingPathComponent("BBA-backup-\(monthString(from: Date())).json")
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - 辅助

    private func exportFolderURL() -> URL {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(AppConstants.Folder.exports, isDirectory: true)
        if !fm.fileExists(atPath: url.path) {
            try? fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }

    private struct MonthRecords {
        var growths: [GrowthRecord]
        var feedings: [FeedingRecord]
        var sleeps: [SleepRecord]
        var diapers: [DiaperRecord]
        var medications: [MedicationRecord]
        var milestones: [Milestone]
        var media: [MediaItem]
    }

    private func recordsInMonth(baby: Baby, month: Date) -> MonthRecords {
        let start = month.startOfMonth
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start) ?? start
        return MonthRecords(
            growths: baby.growthRecords.filter { $0.date >= start && $0.date < end },
            feedings: baby.feedingRecords.filter { $0.startTime >= start && $0.startTime < end },
            sleeps: baby.sleepRecords.filter { $0.startTime >= start && $0.startTime < end },
            diapers: baby.diaperRecords.filter { $0.time >= start && $0.time < end },
            medications: baby.medicationRecords.filter { $0.time >= start && $0.time < end },
            milestones: baby.milestones.filter { $0.achievedDate >= start && $0.achievedDate < end },
            media: baby.mediaItems.filter { $0.capturedDate >= start && $0.capturedDate < end }
        )
    }

    private func calculateExtraPages(for baby: Baby, month: Date) -> Int {
        // 简化:暂定 1 页
        return 0
    }
}

/// 用于导出图片的纯展示视图
struct GrowthChartExportView: View {
    let baby: Baby

    var body: some View {
        VStack(spacing: 16) {
            Text("\(baby.name) 成长曲线")
                .font(.title2.bold())
            Text("生成时间:\(DateUtils.chineseDate.string(from: Date()))")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(["身高(cm)", "体重(kg)", "头围(cm)"], id: \.self) { metric in
                Text(metric)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 这里只展示数据点(导出环境简单些)
                let data = dataFor(metric: metric)
                if !data.isEmpty {
                    GeometryReader { geo in
                        Path { path in
                            let maxV = data.map { $0.value }.max() ?? 1
                            let minV = data.map { $0.value }.min() ?? 0
                            let range = max(maxV - minV, 0.1)
                            for (idx, point) in data.enumerated() {
                                let x = geo.size.width * CGFloat(idx) / CGFloat(max(data.count - 1, 1))
                                let y = geo.size.height - geo.size.height * CGFloat((point.value - minV) / range)
                                if idx == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.accentColor, lineWidth: 2)
                    }
                    .frame(height: 100)
                } else {
                    Text("暂无数据")
                        .foregroundColor(.secondary)
                        .frame(height: 100)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
    }

    private struct Point {
        let month: Int
        let value: Double
    }

    private func dataFor(metric: String) -> [Point] {
        let records = baby.growthRecords.sorted { $0.date < $1.date }
        return records.compactMap { record -> Point? in
            let months = record.ageInMonths()
            if metric.starts(with: "身高"), let v = record.heightCm {
                return Point(month: months, value: v)
            }
            if metric.starts(with: "体重"), let v = record.weightKg {
                return Point(month: months, value: v)
            }
            if metric.starts(with: "头围"), let v = record.headCircumferenceCm {
                return Point(month: months, value: v)
            }
            return nil
        }
    }
}
