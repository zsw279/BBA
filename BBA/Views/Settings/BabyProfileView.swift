//
//  BabyProfileView.swift
//  BBA
//

import SwiftUI
import SwiftData
import PhotosUI

struct BabyProfileView: View {
    let baby: Baby
    @State private var showEdit = false

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
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
                                            .font(.system(size: 60))
                                            .foregroundColor(.appPink)
                                    )
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())

                        Text(baby.name)
                            .font(.title2.bold())
                        Text(baby.ageDisplayString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
            }
            .listRowBackground(Color.clear)

            Section("基本信息") {
                infoRow(label: "姓名", value: baby.name)
                infoRow(label: "性别", value: baby.gender.displayName)
                infoRow(label: "出生日期", value: DateUtils.chineseDate.string(from: baby.birthDate))
                infoRow(label: "月龄", value: "\(baby.ageInMonths)个月")
                if let blood = baby.bloodType {
                    infoRow(label: "血型", value: blood)
                }
            }

            Section {
                Button {
                    showEdit = true
                } label: {
                    Label("编辑资料", systemImage: "pencil")
                }
            }
        }
        .navigationTitle("宝宝档案")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            EditBabyView(baby: baby)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
