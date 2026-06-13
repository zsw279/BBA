//
//  ReminderSettingsView.swift
//  BBA
//
//  提醒设置 - 通知权限入口
//

import SwiftUI

struct ReminderSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.accentColor)
                    Text("通知权限")
                    Spacer()
                    Text(statusText)
                        .foregroundColor(statusColor)
                }

                if notificationService.authorizationStatus != .authorized {
                    Button {
                        Task {
                            _ = await notificationService.requestAuthorization()
                        }
                    } label: {
                        Label("申请通知权限", systemImage: "bell.badge")
                    }
                }
            } header: {
                Text("权限")
            } footer: {
                Text("开启通知后,提醒会通过系统通知中心发出")
            }

            Section("已注册提醒类别") {
                ForEach(categories, id: \.title) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(item.color)
                            .frame(width: 24)
                        Text(item.title)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .navigationTitle("提醒设置")
        .task {
            await notificationService.refreshAuthStatus()
        }
    }

    private var statusText: String {
        switch notificationService.authorizationStatus {
        case .authorized: return "已授权"
        case .denied: return "已拒绝"
        case .notDetermined: return "未设置"
        case .provisional: return "临时授权"
        case .ephemeral: return "临时"
        @unknown default: return "未知"
        }
    }

    private var statusColor: Color {
        switch notificationService.authorizationStatus {
        case .authorized, .provisional: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        default: return .secondary
        }
    }

    private let categories: [(title: String, icon: String, color: Color)] = [
        ("喂养提醒", "drop.fill", .blue),
        ("睡眠提醒", "moon.fill", .purple),
        ("用药提醒", "pills.fill", .red),
        ("尿布提醒", "drop.triangle.fill", .green),
        ("里程碑", "sparkles", .orange),
        ("自定义", "bell.fill", .pink)
    ]
}
