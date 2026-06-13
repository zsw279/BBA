//
//  UnitConverter.swift
//  BBA
//
//  单位换算工具(内部统一 cm/kg,UI 层换算)
//

import Foundation

enum UnitConverter {
    // MARK: - 长度

    /// cm → inch
    static func cmToInch(_ cm: Double) -> Double {
        cm / 2.54
    }

    /// inch → cm
    static func inchToCm(_ inch: Double) -> Double {
        inch * 2.54
    }

    // MARK: - 体重

    /// kg → lb
    static func kgToLb(_ kg: Double) -> Double {
        kg * 2.20462262
    }

    /// lb → kg
    static func lbToKg(_ lb: Double) -> Double {
        lb / 2.20462262
    }

    // MARK: - 显示

    /// 把内部 cm 值格式化为用户单位
    static func formatHeight(_ cm: Double?, unit: String) -> String {
        guard let cm = cm else { return "-" }
        if unit == "inch" {
            return String(format: "%.1f in", cmToInch(cm))
        }
        return String(format: "%.1f cm", cm)
    }

    /// 把内部 kg 值格式化为用户单位
    static func formatWeight(_ kg: Double?, unit: String) -> String {
        guard let kg = kg else { return "-" }
        if unit == "lb" {
            return String(format: "%.2f lb", kgToLb(kg))
        }
        return String(format: "%.2f kg", kg)
    }

    /// 体积:ml → fl oz (可选)
    static func formatVolume(_ ml: Double?, unit: String = "ml") -> String {
        guard let ml = ml else { return "-" }
        if unit == "oz" {
            return String(format: "%.1f fl oz", ml / 29.5735)
        }
        return String(format: "%.0f ml", ml)
    }
}
