//
//  MediaView.swift
//  BBA
//
//  媒体 Tab - 照片视频
//

import SwiftUI
import SwiftData
import PhotosUI

struct MediaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @State private var viewModel: MediaViewModel?
    @State private var showAddMedia = false
    @State private var selectedItem: MediaItem?

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let baby = babies.first, let vm = viewModel {
                    if baby.mediaItems.isEmpty {
                        EmptyStateView(
                            icon: "photo.on.rectangle.angled",
                            title: "还没有照片或视频",
                            message: "记录宝宝成长的高光时刻",
                            actionTitle: "添加",
                            action: { showAddMedia = true }
                        )
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 4) {
                                ForEach(baby.mediaItems.sorted { $0.capturedDate > $1.capturedDate }) { item in
                                    MediaThumbnail(item: item)
                                        .onTapGesture {
                                            selectedItem = item
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                MediaService.shared.deleteMedia(item, in: modelContext)
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(4)
                        }
                        .background(Color(.systemBackground))
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("媒体")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddMedia = true
                        HapticService.light()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil, let baby = babies.first {
                viewModel = MediaViewModel(baby: baby)
            }
        }
        .sheet(isPresented: $showAddMedia) {
            if let baby = babies.first {
                AddMediaView(baby: baby)
            }
        }
        .sheet(item: $selectedItem) { item in
            MediaViewerView(item: item)
        }
    }
}

struct MediaThumbnail: View {
    let item: MediaItem
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: item.mediaType == .video ? "video" : "photo")
                            .foregroundColor(.secondary)
                    )
            }
            if item.mediaType == .video {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "video.fill")
                            .foregroundColor(.white)
                            .font(.caption2)
                        if let duration = item.duration {
                            Text(formatDuration(duration))
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(4)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(maxWidth: .infinity)
        .clipped()
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        if item.mediaType == .video {
            if let url = item.thumbnailURL ?? item.fileURL {
                image = await MediaStorage.shared.generateThumbnail(for: url)
            }
        } else if let url = item.fileURL {
            image = UIImage(contentsOfFile: url.path)
        }
    }

    private func formatDuration(_ d: Double) -> String {
        let m = Int(d) / 60
        let s = Int(d) % 60
        return String(format: "%d:%02d", m, s)
    }
}
