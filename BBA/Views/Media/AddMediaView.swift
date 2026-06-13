//
//  AddMediaView.swift
//  BBA
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddMediaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let baby: Baby

    @State private var viewModel: MediaViewModel?
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var videoItems: [PhotosPickerItem] = []
    @State private var capturedDate: Date = Date()
    @State private var caption: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    Form {
                        Section("时间") {
                            DatePicker("拍摄时间", selection: $capturedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                        }
                        Section("添加照片") {
                            PhotosPicker(
                                selection: $photoItems,
                                maxSelectionCount: 20,
                                matching: .images
                            ) {
                                Label("从相册选择照片", systemImage: "photo.badge.plus")
                            }
                            if !photoItems.isEmpty {
                                Text("已选 \(photoItems.count) 张")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Section("添加视频") {
                            PhotosPicker(
                                selection: $videoItems,
                                maxSelectionCount: 5,
                                matching: .videos
                            ) {
                                Label("从相册选择视频", systemImage: "video.badge.plus")
                            }
                            if !videoItems.isEmpty {
                                Text("已选 \(videoItems.count) 个")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Section("说明") {
                            TextField("为这组记录添加说明(可选)", text: $caption, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                        }
                        if vm.isUploading {
                            Section {
                                HStack {
                                    ProgressView()
                                    Text(vm.uploadProgress)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("添加媒体")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(photoItems.isEmpty && videoItems.isEmpty)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MediaViewModel(baby: baby)
            }
        }
    }

    private func save() {
        guard let vm = viewModel else { return }
        let photoSnapshot = photoItems
        let videoSnapshot = videoItems
        vm.photoItems = photoSnapshot
        vm.videoItems = videoSnapshot

        Task {
            await vm.handlePickedPhotos(in: modelContext)
            await vm.handlePickedVideos(in: modelContext)
            await MainActor.run {
                dismiss()
            }
        }
    }
}
