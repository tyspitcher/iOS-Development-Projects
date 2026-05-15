//
//  DiscoverViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import SwiftUI

struct DiscoverViewModel {
    let appState: AppState

    var filteredItems: [ThreadItem] {
        appState.filteredItems
    }

    var selectedFilter: DiscoverFeedFilter {
        appState.discoverFilter
    }

    var hasResults: Bool {
        !filteredItems.isEmpty
    }

    func tileWidth(for availableWidth: CGFloat, spacing: CGFloat) -> CGFloat {
        max(120, (availableWidth - spacing) / 2)
    }

    func owner(for item: ThreadItem) -> UserProfile? {
        appState.owner(for: item)
    }

    func selectFilter(_ filter: DiscoverFeedFilter) {
        appState.discoverFilter = filter
    }

    func doubleTapLike(_ item: ThreadItem) {
        appState.toggleLike(for: item.id)
    }

    func resetFilters() {
        appState.resetFilters()
    }
}
