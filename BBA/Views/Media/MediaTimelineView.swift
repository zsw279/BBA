//
//  MediaTimelineView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct MediaTimelineView: View {
    let mediaItems: [MediaItem]
    @State private var selectedItem: MediaItem?

    private var groupedByMonth: [(String, [MediaItem])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月"
        let grouped = Dictionary(grouping: mediaItems) { formatter.string(from: $0.capturedDate) }
        return grouped.sorted { lhs, rhs in
            guard let l = mediaItems.first(where: { formatter.string(from: $0.capturedDate) == lhs.key }),
                  let r = mediaItems.first(where: { formatter.string(from: $0.capturedDate) == rhs.key }) else { return false }
            return l.capturedDate > r.capturedDate
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedByMonth, id: \.0) { (month, items) in
                    Section {
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(items) { item in
                                MediaThumbnail(item: item)
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                            }
                        }
                    } header: {
                        HStack {
                            Text(month)
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 16)
        }
        .sheet(item: $selectedItem) { item in
            MediaViewerView(item: item)
        }
    }
}
