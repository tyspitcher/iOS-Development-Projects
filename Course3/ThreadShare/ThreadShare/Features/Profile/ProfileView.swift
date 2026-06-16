//
//  ProfileView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

private enum ProfileSheet: Identifiable {
    case addItem
    case editProfile(UserProfile)

    var id: String {
        switch self {
        case .addItem:
            "add-item"
        case let .editProfile(user):
            "edit-profile-\(user.id.uuidString)"
        }
    }
}

enum ProfileConnectionsSheet: Identifiable {
    case friends
    case followers
    case following

    var id: String {
        switch self {
        case .friends:
            "friends"
        case .followers:
            "followers"
        case .following:
            "following"
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var likedItemsFilter: LikedItemsFilter = .thisWeek
    @State private var activeSheet: ProfileSheet?
    @State private var activeConnectionsSheet: ProfileConnectionsSheet?
    @State private var isShowingFriendList = false

    private var viewModel: ProfileViewModel {
        ProfileViewModel(appState: appState)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .topTrailing) {
                    AppTheme.background.ignoresSafeArea()

                    let contentWidth = max(0, proxy.size.width - (AppTheme.pagePadding * 2))

                    ScrollView {
                        VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                            topHeader

                            if let currentUser = viewModel.currentUser {
                                profileHeader(for: currentUser)
                                friendRequestSummaryCard
                                visibilityCard(for: currentUser)
                                statsCard(for: currentUser)
                                chipSection(
                                    title: "Style Interests",
                                    values: currentUser.styleInterestDisplayNames,
                                    fallback: FashionPreferenceCatalog.displayNames(
                                        forStyleIDs: [
                                            FashionPreferenceCatalog.StyleID.casualEveryday,
                                            FashionPreferenceCatalog.StyleID.vintage
                                        ]
                                    )
                                )
                                chipSection(title: "Favorite Brands", values: currentUser.favoriteBrands, fallback: ["Aritzia", "Madewell"])
                                chipSection(
                                    title: "Color Palettes",
                                    values: currentUser.colorPalettePreferenceDisplayNames,
                                    fallback: ["Soft Neutrals", "Coastal"]
                                )
                                likedItemsSection
                                closet(for: currentUser, availableWidth: contentWidth)
                            } else {
                                EmptyStateView(
                                    title: "Profile loading",
                                    message: "Your closet and profile details will appear here.",
                                    systemImage: "person.crop.circle"
                                )
                            }
                        }
                        .padding(AppTheme.pagePadding)
                    }

                    topActionButtons
                        .padding(.trailing, AppTheme.pagePadding)
                        .padding(.top, proxy.safeAreaInsets.top + AppTheme.tightSpacing)
                }
            }
            .navigationTitle("")
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addItem:
                    AddItemSheetView()
                        .environmentObject(appState)
                case let .editProfile(user):
                    EditProfileSheetView(user: user)
                        .environmentObject(appState)
                }
            }
            .sheet(item: $activeConnectionsSheet) { sheet in
                ProfileConnectionsManagementView(kind: sheet)
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $isShowingFriendList) {
                FriendListView()
                    .environmentObject(appState)
            }
        }
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
            ThreadShareLogoText()

            Text("Profile")
                .font(AppTheme.titleFont(size: 32))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.trailing, 120)
    }

    private var topActionButtons: some View {
        HStack(spacing: AppTheme.tightSpacing) {
            NavigationLink {
                NotificationCenterView()
                    .environmentObject(appState)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                        .frame(width: 34, height: 34)
                        .background(AppTheme.surface, in: Circle())
                        .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))

                    if viewModel.unreadNotificationCount > 0 {
                        Text("\(min(viewModel.unreadNotificationCount, 99))")
                            .font(AppTheme.bodyFont(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .padding(1)
                            .background(AppTheme.clay, in: Capsule())
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Notifications")

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.surface, in: Circle())
                    .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func profileHeader(for user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                UserAvatarView(imageName: user.avatarImageName, size: 82)
                    .overlay(Circle().stroke(AppTheme.surface, lineWidth: 4))
                    .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 7)

                VStack(alignment: .leading, spacing: AppTheme.xSmallSpacing) {
                    Text(user.displayName)
                        .font(AppTheme.titleFont(size: 30))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    Text("@\(user.username)")
                        .font(AppTheme.bodyFont(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.mutedInk)

                    Text(user.city)
                        .font(AppTheme.bodyFont(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.softInk)
                }

                Spacer()
            }

            Text(user.bio)
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.ink.opacity(0.84))
                .fixedSize(horizontal: false, vertical: true)

            SecondaryButton(title: "Edit Profile", systemImage: "pencil") {
                activeSheet = .editProfile(user)
            }

            SecondaryButton(
                title: "Friends (\(viewModel.friendCount))",
                systemImage: "person.2.fill"
            ) {
                isShowingFriendList = true
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 18, x: 0, y: 10)
    }

    private var friendRequestSummaryCard: some View {
        let incomingFriendCount = viewModel.incomingFriendRequestCount
        let incomingFollowCount = viewModel.incomingFollowRequestCount
        let incomingCount = viewModel.totalIncomingRequestCount
        let sentCount = viewModel.requestedFriendCount + viewModel.requestedFollowCount

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle("Requests")
                Spacer()
                InfoChip(
                    title: "\(incomingCount) Incoming",
                    systemImage: "person.crop.circle.badge.plus",
                    tint: incomingCount > 0 ? AppTheme.accent : AppTheme.mutedInk
                )
            }

            Text(requestSummaryText(
                incomingFriendCount: incomingFriendCount,
                incomingFollowCount: incomingFollowCount,
                sentCount: sentCount
            ))
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)

            SecondaryButton(
                title: incomingCount > 0 ? "Review Requests" : "Find Friends",
                systemImage: incomingCount > 0 ? "bell.fill" : "magnifyingglass"
            ) {
                isShowingFriendList = true
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func requestSummaryText(
        incomingFriendCount: Int,
        incomingFollowCount: Int,
        sentCount: Int
    ) -> String {
        if incomingFriendCount > 0 || incomingFollowCount > 0 {
            return "\(incomingFriendCount) friend request\(incomingFriendCount == 1 ? "" : "s") and \(incomingFollowCount) follower request\(incomingFollowCount == 1 ? "" : "s") waiting for review."
        }

        if sentCount > 0 {
            return "\(sentCount) sent request\(sentCount == 1 ? "" : "s") waiting for approval."
        }

        return "Search for classmates, style friends, and follower requests in one place."
    }

    private func visibilityCard(for user: UserProfile) -> some View {
        let closetIsPublic = user.visibility == .publicProfile
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle("Profile Visibility")
                Spacer()
                InfoChip(title: user.visibility.displayName, systemImage: "eye.fill", tint: AppTheme.accent)
            }

            HStack(spacing: 10) {
                InfoChip(
                    title: closetIsPublic ? "Public Closet" : "Private Closet",
                    systemImage: closetIsPublic ? "globe.americas.fill" : "lock.fill",
                    tint: closetIsPublic ? AppTheme.moss : AppTheme.clay
                )

                Text("Update visibility in Edit Profile.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func statsCard(for user: UserProfile) -> some View {
        let stats = viewModel.stats(for: user)
        let canManageConnections = appState.isCurrentUser(id: user.id) && appState.canManageFollowGraph

        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                ProfileStat(value: "\(stats.friends)", title: "Friends", showsDisclosureIndicator: canManageConnections, action: canManageConnections ? { activeConnectionsSheet = .friends } : nil)
                ProfileStat(value: "\(stats.followers)", title: "Followers", showsDisclosureIndicator: canManageConnections, action: canManageConnections ? { activeConnectionsSheet = .followers } : nil)
                ProfileStat(value: "\(stats.following)", title: "Following", showsDisclosureIndicator: canManageConnections, action: canManageConnections ? { activeConnectionsSheet = .following } : nil)
            }

            HStack(spacing: 10) {
                ProfileStat(value: "\(stats.closetItems)", title: "Closet Items")
                ProfileStat(value: "\(stats.availableToLend)", title: "Available")
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func chipSection(title: String, values: [String], fallback: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 116), spacing: 9)], alignment: .leading, spacing: 9) {
                ForEach(values.isEmpty ? fallback : values, id: \.self) { value in
                    InfoChip(title: value, systemImage: "sparkles", tint: AppTheme.accent)
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func closet(for user: UserProfile, availableWidth: CGFloat) -> some View {
        let closetIsPublic = user.visibility == .publicProfile
        let items = viewModel.closetItems(for: user)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle("My Closet")
                Spacer()
                InfoChip(
                    title: closetIsPublic ? "Public" : "Private",
                    systemImage: closetIsPublic ? "globe.americas.fill" : "lock.fill",
                    tint: closetIsPublic ? AppTheme.moss : AppTheme.clay
                )
                Button {
                    activeSheet = .addItem
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(AppTheme.accent, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add item")
            }

            if items.isEmpty {
                EmptyStateView(
                    title: "Your closet is ready",
                    message: "Add your first piece when the upload flow is connected.",
                    systemImage: "hanger"
                )
            } else {
                ThreadMasonryGrid(
                    items: items,
                    spacing: 14,
                    availableWidth: availableWidth,
                    heightForItem: { item, tileWidth in
                        ProfileClosetTile.estimatedHeight(for: item, tileWidth: tileWidth)
                    },
                    content: { item, tileWidth in
                        NavigationLink {
                            ThreadItemDetailView(item: item)
                        } label: {
                            ProfileClosetTile(item: item, tileWidth: tileWidth)
                        }
                        .buttonStyle(.plain)
                    }
                )
            }
        }
    }

    private var likedItemsSection: some View {
        let likedItems = viewModel.likedItems(filter: likedItemsFilter)

        return VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Liked Items")

            Picker("Liked item time range", selection: $likedItemsFilter) {
                ForEach(LikedItemsFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.segmented)

            if likedItems.isEmpty {
                EmptyStateView(
                    title: "No liked pieces yet",
                    message: "Double tap a tile in Discover to save favorites here.",
                    systemImage: "heart"
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(likedItems) { item in
                        NavigationLink {
                            ThreadItemDetailView(item: item)
                        } label: {
                            HStack(spacing: 12) {
                                TileImageFallback(item: item)
                                    .frame(width: 56, height: 56)
                                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(AppTheme.bodyFont(size: 14))
                                        .foregroundStyle(AppTheme.ink)
                                        .lineLimit(1)

                                    Text(item.brand)
                                        .font(AppTheme.bodyFont(size: 12))
                                        .foregroundStyle(AppTheme.mutedInk)
                                        .lineLimit(1)

                                    Text(viewModel.likedDateLabel(for: item))
                                        .font(AppTheme.bodyFont(size: 11))
                                        .foregroundStyle(AppTheme.softInk)
                                }

                                Spacer()

                                Label("\(item.likesCount)", systemImage: item.isLikedByCurrentUser ? "heart.fill" : "heart")
                                    .font(AppTheme.bodyFont(size: 12))
                                    .foregroundStyle(item.isLikedByCurrentUser ? AppTheme.accent : AppTheme.mutedInk)
                            }
                            .padding(10)
                            .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct ProfileStat: View {
    let value: String
    let title: String
    var showsDisclosureIndicator = false
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 4) {
                Text(value)
                    .font(AppTheme.titleFont(size: 18))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text(title)
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity)

                if showsDisclosureIndicator {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedInk.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

private struct ProfileClosetTile: View {
    let item: ThreadItem
    let tileWidth: CGFloat
    private var tileHeight: CGFloat {
        tileWidth * ThreadItemImageSizing.heightRatio(for: item)
    }

    static func estimatedHeight(for item: ThreadItem, tileWidth: CGFloat) -> CGFloat {
        tileWidth * ThreadItemImageSizing.heightRatio(for: item) + 78
    }
    private var tileShape: some Shape {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
    }

    var body: some View {
        TileImageFallback(item: item)
            .frame(width: tileWidth, height: tileHeight)
            .clipShape(tileShape)
            .background {
                tileShape
                    .fill(AppTheme.surface.opacity(0.001))
                    .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
            }
            .overlay(
                tileShape
                    .stroke(AppTheme.strongBorder, lineWidth: 1)
            )
            .contentShape(tileShape)
            .accessibilityLabel("\(item.title), tap for details")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}
