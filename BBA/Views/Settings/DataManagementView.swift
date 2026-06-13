//
//  DataManagementView.swift
//  BBA
//
//  数据管理 - 存储占用、清理等
//

import SwiftUI
import SwiftData

struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    let baby: Baby
    @State private var storageSize: Int64 = 0
    @State private var showDeleteConfirm = false
    @State private var showAllDeleteConfirm = false

    var body: some View {
        List {
            Section("存储") {
                infoRow(label: "宝宝档案", value: "1")
                infoRow(label: "成长记录", value: "\(baby.growthRecords.count)")
                infoRow(label: "喂养记录", value: "\(baby.feedingRecords.count)")
                infoRow(label: "睡眠记录", value: "\(baby.sleepRecords.count)")
                infoRow(label: "尿布记录", value: "\(baby.diaperRecords.count)")
                infoRow(label: "用药记录", value: "\(baby.medicationRecords.count)")
                infoRow(label: "里程碑", value: "\(baby.milestones.count)")
                infoRow(label: "照片/视频", value: "\(baby.mediaItems.count)")
                infoRow(label: "提醒", value: "\(baby.reminders.count)")
                HStack {
                    Text("媒体占用")
                    Spacer()
                    Text(storageSize.fileSizeString)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Button {
                    Task {
                        await MediaStorage.shared // 触发初始化
                        await MainActor.run {
                            storageSize = MediaStorage.shared.totalStorageSize()
                        }
                    }
                } label: {
                    Label("刷新存储", systemImage: "arrow.clockwise")
                }
            }

            Section {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Label("删除所有媒体文件", systemImage: "photo.badge.minus")
                        .foregroundColor(.orange)
                }
            } footer: {
                Text("仅删除已导入的媒体文件,不会影响其他数据")
            }

            Section {
                Button(role: .destructive) {
                    showAllDeleteConfirm = true
                } label: {
                    Label("删除宝宝档案及全部数据", systemImage: "trash")
                }
            } footer: {
                Text("此操作不可撤销,会删除所有关联记录")
            }
        }
        .navigationTitle("数据管理")
        .onAppear {
            storageSize = MediaStorage.shared.totalStorageSize()
        }
        .confirmDialog(
            isPresented: $showDeleteConfirm,
            title: "删除所有媒体?",
            message: "将删除全部已保存的照片和视频文件",
            confirmTitle: "删除",
            isDestructive: true
        ) {
            for item in baby.mediaItems {
                MediaService.shared.deleteMedia(item, in: modelContext)
            }
            storageSize = 0
        }
        .confirmDialog(
            isPresented: $showAllDeleteConfirm,
            title: "删除宝宝档案?",
            message: "将永久删除 \(baby.name) 的所有数据,包括记录、媒体、提醒",
            confirmTitle: "全部删除",
            isDestructive: true
        ) {
            BabyService.shared.deleteBaby(baby, in: modelContext)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
