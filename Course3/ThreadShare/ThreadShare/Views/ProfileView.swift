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

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var likedItemsFilter: LikedItemsFilter = .thisWeek
    @State private var activeSheet: ProfileSheet?
    @State private var isShowingFriendList = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("ThreadShare")
                            .font(AppTheme.brandFont(size: 40))
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.ink)

                        Text("Profile")
                            .font(AppTheme.titleFont(size: 26))
                            .foregroundStyle(AppTheme.ink)
                        if let currentUser = appState.currentUser {
                            profileHeader(for: currentUser)
                            friendRequestSummaryCard
                            visibilityCard(for: currentUser)
                            statsCard(for: currentUser)
                            chipSection(title: "Style Interests", values: currentUser.styleInterests, fallback: ["Campus Casual", "Capsule Closet"])
                            chipSection(title: "Favorite Brands", values: currentUser.favoriteBrands, fallback: ["Aritzia", "Madewell"])
                            likedItemsSection
                            closet(for: currentUser)
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
            }
            .navigationTitle("")
            #if os(iOS)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            #endif
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
            .navigationDestination(isPresented: $isShowingFriendList) {
                FriendListView()
                    .environmentObject(appState)
            }
        }
    }

    private func profileHeader(for user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                UserAvatarView(imageName: user.avatarImageName, size: 82)
                    .overlay(Circle().stroke(AppTheme.surface, lineWidth: 4))
                    .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 7)

                VStack(alignment: .leading, spacing: 7) {
                    Text(user.displayName)
                        .font(AppTheme.titleFont(size: 30))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    Text("@\(user.username)")
                        .font(AppTheme.bodyFont(size: 15))
                        .foregroundStyle(AppTheme.mutedInk)

                    Text(user.city)
                        .font(AppTheme.bodyFont(size: 12))
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
                title: "Friends (\(appState.friends.count))",
                systemImage: "person.2.fill"
            ) {
                isShowingFriendList = true
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 18, x: 0, y: 10)
    }

    private var friendRequestSummaryCard: some View {
        let incomingCount = appState.incomingFriendRequests.count
        let sentCount = appState.requestedFriends.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle("Friend Requests")
                Spacer()
                InfoChip(
                    title: "\(incomingCount) Incoming",
                    systemImage: "person.crop.circle.badge.plus",
                    tint: incomingCount > 0 ? AppTheme.accent : AppTheme.mutedInk
                )
            }

            Text(sentCount > 0 ? "\(sentCount) sent request\(sentCount == 1 ? "" : "s") waiting for approval." : "Search for classmates and style friends from your friends list.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)

            SecondaryButton(
                title: incomingCount > 0 ? "Review Requests" : "Find Friends",
                systemImage: incomingCount > 0 ? "bell.fill" : "magnifyingglass"
            ) {
                isShowingFriendList = true
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
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
        let closetItems = appState.items(for: user)
        let friendCount = appState.users.filter { $0.id != user.id && $0.relationship == .friend }.count
        let availableCount = closetItems.filter { $0.availabilityStatus == .available }.count

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
            ProfileStat(value: "\(closetItems.count)", title: "Closet Items")
            ProfileStat(value: "\(friendCount)", title: "Friends")
            ProfileStat(value: "\(user.followerCount)", title: "Followers")
            ProfileStat(value: "\(user.followingCount)", title: "Following")
            ProfileStat(value: "\(availableCount)", title: "Available")
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

    private func closet(for user: UserProfile) -> some View {
        let closetIsPublic = user.visibility == .publicProfile

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

            let items = appState.items(for: user)
            if items.isEmpty {
                EmptyStateView(
                    title: "Your closet is ready",
                    message: "Add your first piece when the upload flow is connected.",
                    systemImage: "hanger"
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink {
                            ThreadItemDetailView(item: item)
                        } label: {
                            ProfileClosetTile(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var likedItemsSection: some View {
        let likedItems = appState.likedItems(filter: likedItemsFilter)

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
                                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(AppTheme.bodyFont(size: 14))
                                        .foregroundStyle(AppTheme.ink)
                                        .lineLimit(1)

                                    Text(item.brand)
                                        .font(AppTheme.bodyFont(size: 12))
                                        .foregroundStyle(AppTheme.mutedInk)
                                        .lineLimit(1)

                                    Text(likedDateLabel(for: item))
                                        .font(AppTheme.bodyFont(size: 11))
                                        .foregroundStyle(AppTheme.softInk)
                                }

                                Spacer()

                                Label("\(item.likesCount)", systemImage: item.isLikedByCurrentUser ? "heart.fill" : "heart")
                                    .font(AppTheme.bodyFont(size: 12))
                                    .foregroundStyle(item.isLikedByCurrentUser ? AppTheme.accent : AppTheme.mutedInk)
                            }
                            .padding(10)
                            .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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

    private func likedDateLabel(for item: ThreadItem) -> String {
        guard let likedAt = item.likedAt else { return "Liked date unavailable" }
        return "Liked \(likedAt.formatted(date: .abbreviated, time: .omitted))"
    }
}

private struct ProfileStat: View {
    let value: String
    let title: String

    var body: some View {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
    }
}

private struct ProfileClosetTile: View {
    let item: ThreadItem

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            TileImageFallback(item: item)
                .aspectRatio(1 / ThreadItemImageSizing.heightRatio(for: item), contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))

            Text(item.title)
                .font(AppTheme.bodyFont(size: 14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(2)

            HStack {
                Text(item.brand)
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(1)

                Spacer()

                AvailabilityBadge(status: item.availabilityStatus)
            }
        }
        .padding(8)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}
