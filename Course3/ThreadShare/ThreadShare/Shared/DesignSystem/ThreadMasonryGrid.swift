//
//  ThreadMasonryGrid.swift
//  ThreadShare
//
//  Created by Codex on 6/3/26.
//

import SwiftUI

struct ThreadMasonryGrid<Item: Identifiable, Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let items: [Item]
    let spacing: CGFloat
    let availableWidth: CGFloat
    let columnCount: Int? = nil
    let heightForItem: (Item, CGFloat) -> CGFloat
    let content: (Item, CGFloat) -> Content

    private var resolvedColumnCount: Int {
        columnCount ?? (horizontalSizeClass == .regular ? 3 : 2)
    }

    private var tileWidth: CGFloat {
        let columns = max(resolvedColumnCount, 1)
        let totalSpacing = spacing * CGFloat(max(columns - 1, 0))
        return max(120, (availableWidth - totalSpacing) / CGFloat(columns))
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<max(resolvedColumnCount, 1), id: \.self) { columnIndex in
                LazyVStack(spacing: spacing) {
                    ForEach(columnItems[columnIndex]) { item in
                        content(item, tileWidth)
                            .frame(width: tileWidth)
                            .clipped()
                    }
                }
                .frame(width: tileWidth)
                .clipped()
            }
        }
        .frame(width: availableWidth, alignment: .topLeading)
    }

    private var columnItems: [[Item]] {
        let columns = max(resolvedColumnCount, 1)
        var distributed = Array(repeating: [Item](), count: columns)
        var heights = Array(repeating: CGFloat.zero, count: columns)

        for item in items {
            guard let targetColumn = heights.enumerated().min(by: { $0.element < $1.element })?.offset else {
                continue
            }

            distributed[targetColumn].append(item)
            heights[targetColumn] += heightForItem(item, tileWidth) + spacing
        }

        return distributed
    }
}
