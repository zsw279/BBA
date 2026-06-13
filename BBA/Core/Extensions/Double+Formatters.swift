//
//  Double+Formatters.swift
//  BBA
//

import Foundation

extension Double {
    /// 体积(ml)格式化
    var milliliterString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") ml"
    }

    /// 长度(cm)格式化
    var centimeterString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") cm"
    }

    /// 体重(kg)格式化
    var kilogramString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") kg"
    }

    /// 百分比
    var percentString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }

    /// 字节大小
    var fileSizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(self))
    }
}

extension TimeInterval {
    /// 时长格式化为 "1h 23m" 或 "23m 45s"
    var durationString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        if hours > 0 {
            return String(format: "%d小时%02d分", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d分%02d秒", minutes, seconds)
        } else {
            return "\(seconds)秒"
        }
    }

    /// 简短格式 "1:23:45" 或 "23:45"
    var clockString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
