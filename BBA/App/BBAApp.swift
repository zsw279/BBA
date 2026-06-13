//
//  BBAApp.swift
//  BBA
//
//  应用入口 - 创建 ModelContainer,挂载通知中心
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct BBAApp: App {
    /// 共享的 SwiftData 容器
    let modelContainer: ModelContainer

    /// 通知服务(单例)
    @StateObject private var notificationService = NotificationService.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        self.modelContainer = SharedModelContainer.shared.container
        AppDelegate.notificationService = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .environmentObject(notificationService)
                .onAppear {
                    requestNotificationPermissionIfNeeded()
                }
        }
    }

    private func requestNotificationPermissionIfNeeded() {
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }
}
