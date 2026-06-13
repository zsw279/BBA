//
//  SettingsView.swift
//  BBA
//
//  我的 Tab - 设置主页
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]

    var body: some View {
        NavigationStack {
            Group {
                if let baby = babies.first {
                    List {
                        Section {
                            NavigationLink {
                                BabyProfileView(baby: baby)
                            } label: {
                                HStack(spacing: 12) {
                                    Group {
                                        if let data = baby.avatarData, let img = UIImage(data: data) {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Circle()
                                                .fill(Color.appPink.opacity(0.2))
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .foregroundColor(.appPink)
                                                )
                                        }
                                    }
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(baby.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(baby.ageDisplayString + " · " + baby.gender.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }

                        Section("功能") {
                            NavigationLink {
                                ReminderListView()
                            } label: {
                                Label("提醒", systemImage: "bell.fill")
                            }
                            NavigationLink {
                                ReminderSettingsView()
                            } label: {
                                Label("通知设置", systemImage: "bell.badge")
                            }
                            NavigationLink {
                                PreferencesView(baby: baby)
                            } label: {
                                Label("偏好设置", systemImage: "gearshape")
                            }
                        }

                        Section("数据") {
                            NavigationLink {
                                ExportView(baby: baby)
                            } label: {
                                Label("导出 / 备份", systemImage: "square.and.arrow.up")
                            }
                            NavigationLink {
                                DataManagementView(baby: baby)
                            } label: {
                                Label("数据管理", systemImage: "externaldrive")
                            }
                        }

                        Section("关于") {
                            NavigationLink {
                                AboutView()
                            } label: {
                                Label("关于 BBA", systemImage: "info.circle")
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("我的")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Baby.self, inMemory: true)
}
