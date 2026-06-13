//
//  AgeCalculator.swift
//  BBA
//
//  月龄/周龄/天数计算与显示
//

import Foundation

enum AgeCalculator {
    /// 显示年龄文案
    /// - Examples:
    ///   - 5天 → "5天"
    ///   - 23天 → "3周2天"
    ///   - 65天 → "2个月5天"
    ///   - 365天 → "1岁"
    static func displayString(from birthDate: Date, to referenceDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: birthDate, to: referenceDate)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let weeks = components.weekOfYear ?? 0
        let days = components.day ?? 0

        if years >= 1 {
            let remainMonths = months - years * 12
            if remainMonths > 0 {
                return "\(years)岁\(remainMonths)个月"
            }
            return "\(years)岁"
        }
        if months >= 1 {
            return "\(months)个月\(days - months * 30)天"
        }
        if weeks >= 1 {
            return "\(weeks)周\(days - weeks * 7)天"
        }
        return "\(days)天"
    }

    /// 月龄(向下取整)
    static func monthsBetween(from start: Date, to end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: start, to: end)
        return components.month ?? 0
    }

    /// 完整月数(含小数,用于图表)
    static func preciseMonthsBetween(from start: Date, to end: Date) -> Double {
        let seconds = end.timeIntervalSince(start)
        return seconds / (30.0 * 24 * 3600)
    }
}
