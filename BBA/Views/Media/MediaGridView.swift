//
//  MediaGridView.swift
//  BBA
//
//  通用媒体网格组件
//

import SwiftUI

struct MediaGridView: View {
    let items: [MediaItem]
    var onTap: ((MediaItem) -> Void)? = nil
    @State private var selectedItem: MediaItem?

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(items) { item in
                MediaThumbnail(item: item)
                    .onTapGesture {
                        if let onTap = onTap {
                            onTap(item)
                        } else {
                            selectedItem = item
                        }
                    }
            }
        }
        .sheet(item: $selectedItem) { item in
            MediaViewerView(item: item)
        }
    }
}
