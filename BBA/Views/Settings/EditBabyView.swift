//
//  EditBabyView.swift
//  BBA
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditBabyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var name: String = ""
    @State private var gender: Gender = .other
    @State private var birthDate: Date = Date()
    @State private var bloodType: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("头像") {
                    PhotosPicker(selection: $avatarItem, matching: .images) {
                        HStack {
                            Group {
                                if let data = avatarData ?? baby.avatarData, let img = UIImage(data: data) {
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
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            Text("更换头像")
                                .foregroundColor(.accentColor)
                            Spacer()
                        }
                    }
                    .onChange(of: avatarItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                avatarData = data
                            }
                        }
                    }
                }
                Section("基本信息") {
                    TextField("姓名", text: $name)
                    Picker("性别", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }
                    DatePicker("出生日期", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    Picker("血型", selection: $bloodType) {
                        Text("未知").tag("")
                        ForEach(["A", "B", "AB", "O"], id: \.self) { b in
                            Text(b).tag(b)
                        }
                    }
                }
            }
            .navigationTitle("编辑宝宝")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            name = baby.name
            gender = baby.gender
            birthDate = baby.birthDate
            bloodType = baby.bloodType ?? ""
        }
    }

    private func save() {
        var newAvatarData: Data? = nil
        if let data = avatarData {
            newAvatarData = data
        }
        BabyService.shared.updateBaby(
            baby,
            name: name,
            birthDate: birthDate,
            gender: gender,
            bloodType: .some(bloodType.isEmpty ? nil : bloodType),
            avatarData: .some(newAvatarData)
        )
        try? modelContext.save()
        dismiss()
    }
}
