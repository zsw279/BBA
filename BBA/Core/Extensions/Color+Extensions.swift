//
//  Color+Extensions.swift
//  BBA
//

import SwiftUI

extension Color {
    /// 从 Assets 中读取主题色
    static let appBackground = Color("AppBackground")
    static let appSecondaryBackground = Color("AppSecondaryBackground")
    static let appPink = Color("AppPink")
    static let appBlue = Color("AppBlue")
    static let appGreen = Color("AppGreen")
    static let appOrange = Color("AppOrange")
    static let appYellow = Color("AppYellow")
    static let appPurple = Color("AppPurple")
    static let appRed = Color("AppRed")

    /// 从字符串名称获取主题色(用于枚举)
    static func fromName(_ name: String) -> Color {
        switch name {
        case "blue": return .appBlue
        case "purple": return .appPurple
        case "pink": return .appPink
        case "orange": return .appOrange
        case "yellow": return .appYellow
        case "green": return .appGreen
        case "brown": return .brown
        case "red": return .appRed
        default: return .gray
        }
    }
}
