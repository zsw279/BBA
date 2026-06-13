//
//  DateUtils.swift
//  BBA
//
//  日期/时间格式化工具
//

import Foundation

enum DateUtils {
    static let yearMonthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let monthDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let chineseDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let weekday: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    /// 智能日期显示:
    /// - 今天 → "今天 HH:mm"
    /// - 昨天 → "昨天 HH:mm"
    /// - 本年 → "MM-dd HH:mm"
    /// - 其他 → "yyyy-MM-dd HH:mm"
    static func smartDateString(_ date: Date) -> String {
        if date.isToday {
            return "今天 \(timeOnly.string(from: date))"
        } else if date.isYesterday {
            return "昨天 \(timeOnly.string(from: date))"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            return "\(monthDay.string(from: date)) \(timeOnly.string(from: date))"
        } else {
            return "\(dateTime.string(from: date))"
        }
    }

    /// 仅日期(无时间)
    static func dateOnly(_ date: Date) -> String {
        if date.isToday { return "今天" }
        if date.isYesterday { return "昨天" }
        return chineseDate.string(from: date)
    }
}
