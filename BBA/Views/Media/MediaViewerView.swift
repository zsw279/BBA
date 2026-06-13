//
//  MediaViewerView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct MediaViewerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let item: MediaItem

    @State private var image: UIImage?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                content
                infoPanel
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            await loadMedia()
        }
        .confirmDialog(
            isPresented: $showDeleteConfirm,
            title: "删除这张\(item.mediaType == .video ? "视频" : "照片")?",
            message: "此操作无法撤销",
            confirmTitle: "删除",
            isDestructive: true
        ) {
            MediaService.shared.deleteMedia(item, in: modelContext)
            dismiss()
        }
    }

    @ViewBuilder
    private var content: some View {
        if item.mediaType == .video, let url = item.fileURL {
            VideoPlayerView(url: url)
        } else if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(DateUtils.chineseDate.string(from: item.capturedDate), systemImage: "calendar")
                Spacer()
                if item.mediaType == .video, let duration = item.duration {
                    Label(formatDuration(duration), systemImage: "video")
                } else {
                    Label("\(Int(item.fileSize)) bytes", systemImage: "photo")
                }
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))

            if let caption = item.caption, !caption.isEmpty {
                Text(caption)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
    }

    private func loadMedia() async {
        if item.mediaType == .photo, let url = item.fileURL {
            image = UIImage(contentsOfFile: url.path)
        }
    }

    private func formatDuration(_ d: Double) -> String {
        let m = Int(d) / 60
        let s = Int(d) % 60
        return String(format: "%d:%02d", m, s)
    }
}
