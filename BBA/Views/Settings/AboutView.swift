//
//  AboutView.swift
//  BBA
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.appPink, .appPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("BBA")
                            .font(.largeTitle.bold())
                        Text("宝宝成长记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            Section("功能") {
                feature(icon: "chart.line.uptrend.xyaxis", title: "成长曲线", subtitle: "身高体重头围可视化")
                feature(icon: "drop.fill", title: "日常记录", subtitle: "喂养/睡眠/尿布/用药")
                feature(icon: "sparkles", title: "里程碑", subtitle: "30+ 模板 + 自定义")
                feature(icon: "photo.on.rectangle.angled", title: "照片时间线", subtitle: "留住成长高光")
                feature(icon: "bell.fill", title: "智能提醒", subtitle: "本地通知 + 重复")
                feature(icon: "doc.fill", title: "PDF 导出", subtitle: "月度成长报告")
            }
            Section("声明") {
                Text("BBA 是一款个人开发的宝宝成长记录应用,所有数据仅存储在你的设备本地,我们不会上传任何信息到云端。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("关于")
    }

    private func feature(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
