//
//  DiscoverView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DiscoverView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isShowingFilters = false
    private let tileSpacing: CGFloat = 14

    private var viewModel: DiscoverViewModel {
        DiscoverViewModel(appState: appState)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                GeometryReader { proxy in
                    let contentWidth = max(0, proxy.size.width - (AppTheme.pagePadding * 2))

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 18) {
                            header

                            if !viewModel.hasResults {
                                EmptyStateView(
                                    title: "No pieces match",
                                    message: "Try changing your filters or browsing the full community feed.",
                                    actionTitle: "Reset Filters",
                                    action: viewModel.resetFilters
                                )
                            } else {
                                DiscoverMasonryGrid(
                                    items: viewModel.filteredItems,
                                    spacing: tileSpacing,
                                    availableWidth: contentWidth,
                                    ownerForItem: viewModel.owner(for:),
                                    onDoubleTapLike: viewModel.doubleTapLike
                                )
                            }
                        }
                        .padding(AppTheme.pagePadding)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingFilters) {
                FilterSheetView()
                    .environmentObject(appState)
            }
            .safeAreaInset(edge: .top) {
                filterBar
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(AppTheme.border.opacity(0.75))
                            .frame(height: 1)
                    }
            }
            #if os(iOS)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            #endif
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discover")
                .font(AppTheme.titleFont(size: 30))
                .foregroundStyle(AppTheme.ink)
                .padding(.top, 6)

            Text("ThreadShare")
                .font(AppTheme.brandFont(size: 42))
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.ink)

            Text("DISCOVER THE FIT. BORROW THE LOOK. WEAR THE STORY.")
                .font(AppTheme.titleFont(size: 20))
                .foregroundStyle(AppTheme.ink)
                .padding(.top, -5)
                .lineLimit(2)

            Text("Browse standout pieces from friends, follows, and public closets.")
                .font(AppTheme.bodyFont(size: 21))
                .foregroundStyle(AppTheme.mutedInk)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DiscoverFeedFilter.allCases) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: viewModel.selectedFilter == filter,
                        action: { viewModel.selectFilter(filter) }
                    )
                }

                Button {
                    isShowingFilters = true
                } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                        .font(AppTheme.bodyFont(size: 16))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(AppTheme.accentSoft, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

}

private struct DiscoverMasonryGrid: View {
    let items: [ThreadItem]
    let spacing: CGFloat
    let availableWidth: CGFloat
    let ownerForItem: (ThreadItem) -> UserProfile?
    let onDoubleTapLike: (ThreadItem) -> Void

    private var tileWidth: CGFloat {
        max(120, (availableWidth - spacing) / 2)
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<2, id: \.self) { columnIndex in
                LazyVStack(spacing: spacing) {
                    ForEach(columnItems(columnIndex)) { item in
                        NavigationLink {
                            ThreadItemDetailView(item: item)
                        } label: {
                            DiscoverItemTile(
                                item: item,
                                owner: ownerForItem(item),
                                tileWidth: tileWidth
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(width: tileWidth, height: tileWidth * ThreadItemImageSizing.heightRatio(for: item))
                        .clipped()
                        .simultaneousGesture(
                            TapGesture(count: 2)
                                .onEnded { onDoubleTapLike(item) }
                        )
                    }
                }
                .frame(width: tileWidth)
                .clipped()
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func columnItems(_ column: Int) -> [ThreadItem] {
        items.enumerated().compactMap { index, item in
            index % 2 == column ? item : nil
        }
    }
}

private struct DiscoverItemTile: View {
    let item: ThreadItem
    let owner: UserProfile?
    let tileWidth: CGFloat
    private var tileHeight: CGFloat {
        tileWidth * ThreadItemImageSizing.heightRatio(for: item)
    }
    private var tileShape: some Shape {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack {
            tileShape
                .fill(AppTheme.surface)

            TileImageFallback(item: item)
        }
            .frame(width: tileWidth, height: tileHeight)
            .clipShape(tileShape)
            .background {
                tileShape
                    .fill(AppTheme.surface.opacity(0.001))
                    .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
            }
            .overlay(
                tileShape
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .overlay(alignment: .bottomLeading) {
                imageDock
                    .padding(10)
            }
            .contentShape(tileShape)
            .accessibilityLabel("\(item.title), tap for details")
    }

    private var imageDock: some View {
        HStack(spacing: 8) {
            if item.availabilityStatus == .available, owner?.relationship == .friend {
                Text("Available")
                    .font(AppTheme.bodyFont(size: 11))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(.black.opacity(0.45), in: Capsule())
            }

            if let owner, owner.relationship != .publicUser {
                Image(systemName: owner.relationship == .friend ? "person.2.fill" : "person.crop.circle.badge.checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(.black.opacity(0.45), in: Circle())
            }

            Label("\(item.likesCount)", systemImage: item.isLikedByCurrentUser ? "heart.fill" : "heart")
                .font(AppTheme.bodyFont(size: 11))
                .foregroundStyle(item.isLikedByCurrentUser ? AppTheme.accentSoft : .white)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(.black.opacity(0.45), in: Capsule())
        }
    }
}

struct TileImageFallback: View {
    let item: ThreadItem

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.color(for: item.category).opacity(0.92),
                    AppTheme.color(for: item.category).opacity(0.45),
                    AppTheme.accentSoft.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: iconName)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.white.opacity(0.9))

            if let uiImage = ThreadItemImageStore.uiImage(named: item.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .accessibilityLabel("\(item.title) image")
    }

    private var iconName: String {
        switch item.category {
        case .tops: "tshirt"
        case .bottoms: "figure.stand"
        case .dresses: "sparkles"
        case .shoes: "shoeprints.fill"
        case .sweaters: "hanger"
        case .accessories: "handbag"
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
            .environmentObject(AppState())
    }
}
