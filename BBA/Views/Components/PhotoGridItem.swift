//
//  PhotoGridItem.swift
//  BBA
//
//  媒体网格单元
//

import SwiftUI

struct PhotoGridItem: View {
    let image: UIImage?
    let isVideo: Bool
    let duration: Double?
    var onTap: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: { onTap?() }) {
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    }
                    if isVideo {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "video.fill")
                                    .foregroundColor(.white)
                                if let duration = duration {
                                    Text(formatDuration(duration))
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(6)
                            .background(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .black.opacity(0.5))
                }
                .padding(4)
            }
        }
    }

    private func formatDuration(_ d: Double) -> String {
        let m = Int(d) / 60
        let s = Int(d) % 60
        return String(format: "%d:%02d", m, s)
    }
}
