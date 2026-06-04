//
//  FriendListView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var requestMessage: String?
    @State private var pendingUnfriendUser: UserProfile?
    private let selectionAction: ((UserProfile) -> Void)?

    init(selectionAction: ((UserProfile) -> Void)? = nil) {
        self.selectionAction = selectionAction
    }

    private var viewModel: FriendListViewModel {
        FriendListViewModel(appState: appState)
    }

    var body: some View {
        List {
            if selectionAction != nil {
                friendSelectionSection
            } else {
                Section("Find Friends") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(AppTheme.mutedInk)

                            TextField("Search by name or username", text: $searchText)
                                .font(AppTheme.bodyFont(size: 15))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppTheme.mutedInk)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )

                        searchResults
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                Section("Friends") {
                    if viewModel.friends.isEmpty {
                        Text("No friends yet.")
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.mutedInk)
                    } else {
                        ForEach(viewModel.friends) { friend in
                            NavigationLink {
                                UserProfileDetailView(user: friend)
                            } label: {
                                FriendRow(user: friend)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    pendingUnfriendUser = friend
                                } label: {
                                    Label("Unfriend", systemImage: "person.crop.circle.badge.minus")
                                }
                            }
                        }
                    }
                }

                Section("Requested") {
                    if viewModel.requestedFriends.isEmpty {
                        Text("No pending requests sent.")
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.mutedInk)
                    } else {
                        ForEach(viewModel.requestedFriends) { user in
                            NavigationLink {
                                UserProfileDetailView(user: user)
                            } label: {
                                HStack(spacing: 12) {
                                    FriendRow(user: user)
                                    Spacer(minLength: 0)
                                    FriendStatusPill(
                                        title: viewModel.statusTitle(for: user),
                                        systemImage: viewModel.statusIcon(for: user)
                                    )
                                }
                            }
                        }
                    }
                }

                Section("Friend Requests") {
                    if viewModel.incomingFriendRequests.isEmpty {
                        Text("No incoming friend requests.")
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.mutedInk)
                    } else {
                        ForEach(viewModel.incomingFriendRequests) { user in
                            HStack(spacing: 12) {
                                FriendRow(user: user)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing: 8) {
                                    SecondaryButton(title: "", systemImage: "xmark") {
                                        appState.denyFriendRequest(from: user.id)
                                    }
                                    SecondaryButton(title: "", systemImage: "checkmark") {
                                        appState.approveFriendRequest(from: user.id)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Follower Requests") {
                    if viewModel.incomingFollowRequests.isEmpty {
                        Text("No incoming follower requests.")
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.mutedInk)
                    } else {
                        ForEach(viewModel.incomingFollowRequests) { user in
                            HStack(spacing: 12) {
                                NavigationLink {
                                    UserProfileDetailView(user: user)
                                } label: {
                                    FriendRow(user: user)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                HStack(spacing: 8) {
                                    SecondaryButton(title: "", systemImage: "xmark") {
                                        appState.denyFollowRequest(from: user.id)
                                    }
                                    SecondaryButton(title: "", systemImage: "checkmark") {
                                        appState.approveFollowRequest(from: user.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Friends")
        .toolbar {
            if selectionAction != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Friend Request Sent", isPresented: Binding(
            get: { requestMessage != nil },
            set: { if !$0 { requestMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(requestMessage ?? "")
        }
        .alert(item: $pendingUnfriendUser) { user in
            Alert(
                title: Text("Unfriend \(user.displayName)?"),
                message: Text("This will remove \(user.displayName) from your friends list."),
                primaryButton: .destructive(Text("Unfriend")) {
                    _ = appState.removeFriend(user.id)
                },
                secondaryButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private var friendSelectionSection: some View {
        Section("Choose Friend") {
            if viewModel.friends.isEmpty {
                Text("No friends yet.")
                    .font(AppTheme.bodyFont(size: 14))
                    .foregroundStyle(AppTheme.mutedInk)
            } else {
                ForEach(viewModel.friends) { friend in
                    Button {
                        selectionAction?(friend)
                    } label: {
                        FriendRow(user: friend)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        let potentialFriends = viewModel.searchResults(matching: searchText)

        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text("Enter a name or username to search.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
        } else if potentialFriends.isEmpty {
            Text("No matches found.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
        } else {
            VStack(spacing: 8) {
                ForEach(potentialFriends) { user in
                    HStack(spacing: 12) {
                        NavigationLink {
                            UserProfileDetailView(user: user)
                        } label: {
                            FriendRow(user: user)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        searchResultAction(for: user)
                    }
                    .padding(10)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func searchResultAction(for user: UserProfile) -> some View {
        switch viewModel.connectionState(for: user) {
        case .addFriend:
            Button {
                appState.sendFriendRequest(to: user.id)
                requestMessage = viewModel.requestSentMessage(for: user)
            } label: {
                Label("Add Friend", systemImage: "person.badge.plus")
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 11)
                    .frame(height: 34)
                    .background(AppTheme.accentSoft, in: Capsule())
            }
            .buttonStyle(.plain)

        case .requested, .friends:
            FriendStatusPill(
                title: viewModel.statusTitle(for: user),
                systemImage: viewModel.statusIcon(for: user)
            )

        case .incomingRequest:
            VStack(alignment: .trailing, spacing: 8) {
                FriendStatusPill(
                    title: viewModel.statusTitle(for: user),
                    systemImage: viewModel.statusIcon(for: user)
                )

                HStack(spacing: 8) {
                    SecondaryButton(title: "", systemImage: "xmark") {
                        appState.denyFriendRequest(from: user.id)
                    }
                    SecondaryButton(title: "", systemImage: "checkmark") {
                        appState.approveFriendRequest(from: user.id)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Incoming friend request actions")
        }
    }
}

private struct FriendRow: View {
    let user: UserProfile

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(imageName: user.avatarImageName, size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(AppTheme.ink)
                Text("@\(user.username)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

private struct FriendStatusPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(AppTheme.bodyFont(size: 12))
            .foregroundStyle(AppTheme.mutedInk)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(AppTheme.surface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.border, lineWidth: 1)
            }
    }
}

struct UserProfileDetailView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingBlockConfirmation = false
    @State private var isShowingBlockCompleted = false
    @State private var isShowingUnfollowConfirmation = false
    let user: UserProfile

    private var displayedUser: UserProfile {
        appState.user(withID: user.id) ?? user
    }

    private var viewModel: FriendListViewModel {
        FriendListViewModel(appState: appState)
    }

    private var isCurrentUserProfile: Bool {
        viewModel.isCurrentUserProfile(displayedUser)
    }

    private var canViewCloset: Bool {
        viewModel.canViewCloset(for: displayedUser)
    }

    private var followState: FollowConnectionState {
        viewModel.followConnectionState(for: displayedUser)
    }

    private var profileFriendRequests: [UserProfile] {
        viewModel.visibleFriendRequests(on: displayedUser)
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(0, proxy.size.width - (AppTheme.pagePadding * 2))

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        UserAvatarView(imageName: displayedUser.avatarImageName, size: 82)
                            .overlay(Circle().stroke(AppTheme.surface, lineWidth: 4))
                            .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 7)

                        Text(displayedUser.displayName)
                            .font(AppTheme.titleFont(size: 30))
                            .foregroundStyle(AppTheme.ink)
                        Text("@\(displayedUser.username)")
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.mutedInk)
                        Text(displayedUser.bio)
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.ink.opacity(0.85))

                        if !isCurrentUserProfile {
                            VStack(spacing: 10) {
                                profileRelationshipAction
                                profileModerationActions
                            }
                        }
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                    if !profileFriendRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle("Friend Requests")

                            ForEach(profileFriendRequests) { requester in
                                HStack(spacing: 12) {
                                    FriendRow(user: requester)

                                    Spacer()

                                    if isCurrentUserProfile {
                                        HStack(spacing: 8) {
                                            Button {
                                                appState.denyFriendRequest(from: requester.id)
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.caption.weight(.bold))
                                                    .foregroundStyle(AppTheme.mutedInk)
                                                    .frame(width: 32, height: 32)
                                                    .background(AppTheme.surface, in: Circle())
                                                    .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                                            }
                                            .buttonStyle(.plain)

                                            Button {
                                                appState.approveFriendRequest(from: requester.id)
                                            } label: {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.weight(.bold))
                                                    .foregroundStyle(.white)
                                                    .frame(width: 32, height: 32)
                                                    .background(AppTheme.accent, in: Circle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    } else {
                                        FriendStatusPill(title: "Received", systemImage: "tray.fill")
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

                    if canViewCloset {
                        SectionTitle("\(displayedUser.displayName)'s Closet")

                        let items = appState.items(for: displayedUser)
                        if items.isEmpty {
                            EmptyStateView(
                                title: "No closet items yet",
                                message: "This user has not posted any pieces.",
                                systemImage: "hanger"
                            )
                        } else {
                            ThreadMasonryGrid(
                                items: items,
                                spacing: 12,
                                availableWidth: contentWidth,
                                heightForItem: { item, tileWidth in
                                    FriendClosetTile.estimatedHeight(for: item, tileWidth: tileWidth)
                                },
                                content: { item, _ in
                                    NavigationLink {
                                        ThreadItemDetailView(item: item)
                                    } label: {
                                        FriendClosetTile(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            )
                        }
                    } else {
                        EmptyStateView(
                            title: "Closet is private",
                            message: "Add as friend to view this closet.",
                            systemImage: "lock.fill"
                        )
                    }
                }
                .padding(AppTheme.pagePadding)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Block user?", isPresented: $isShowingBlockConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Block User", role: .destructive) {
                if appState.blockUser(displayedUser.id) {
                    isShowingBlockCompleted = true
                }
            }
        } message: {
            Text("This will limit visibility and interactions in ThreadShare. Their items will be hidden from your feed, and they will no longer appear in friend search where practical.")
        }
        .alert("User blocked", isPresented: $isShowingBlockCompleted) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("This user’s content and social surfaces will be limited in ThreadShare.")
        }
        .alert("Unfollow \(displayedUser.displayName)?", isPresented: $isShowingUnfollowConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Unfollow", role: .destructive) {
                appState.toggleFollow(for: displayedUser.id)
            }
        } message: {
            Text("This will stop you from seeing this person's updates in follow-based surfaces. You can follow them again later if you change your mind.")
        }
    }

    @ViewBuilder
    private var profileRelationshipAction: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch viewModel.connectionState(for: displayedUser) {
            case .friends:
                FriendStatusPill(
                    title: viewModel.statusTitle(for: user),
                    systemImage: viewModel.statusIcon(for: user)
                )
            case .requested:
                FriendStatusPill(
                    title: viewModel.statusTitle(for: user),
                    systemImage: viewModel.statusIcon(for: user)
                )
            case .incomingRequest:
                HStack(spacing: 10) {
                    SecondaryButton(title: "Decline", systemImage: "xmark") {
                        appState.denyFriendRequest(from: displayedUser.id)
                    }
                    PrimaryButton(title: "Approve", systemImage: "checkmark") {
                        appState.approveFriendRequest(from: displayedUser.id)
                    }
                }
            case .addFriend:
                PrimaryButton(title: "Request Friend", systemImage: "person.badge.plus") {
                    appState.sendFriendRequest(to: displayedUser.id)
                }
            }
        }
    }

    private var profileModerationActions: some View {
        guard !isCurrentUserProfile else {
            return AnyView(EmptyView())
        }

        return AnyView(
            HStack(spacing: 10) {
                secondaryModerationButton(
                    title: viewModel.followStatusTitle(for: displayedUser),
                    systemImage: viewModel.followStatusIcon(for: displayedUser)
                ) {
                    switch followState {
                    case .following:
                        isShowingUnfollowConfirmation = true
                    case .requested:
                        break
                    case .follow:
                        appState.toggleFollow(for: displayedUser.id)
                    }
                }
                .disabled(followState == .requested)

                if appState.canBlockUser(displayedUser.id) {
                    secondaryModerationButton(title: "Block", systemImage: "hand.raised.fill") {
                        isShowingBlockConfirmation = true
                    }
                }
            }
        )
    }

    private func secondaryModerationButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(AppTheme.bodyFont(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.mutedInk)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.7), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct FriendClosetTile: View {
    let item: ThreadItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TileImageFallback(item: item)
                .aspectRatio(1 / ThreadItemImageSizing.heightRatio(for: item), contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))

            Text(item.title)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(2)

            HStack {
                Text(item.brand)
                    .font(AppTheme.bodyFont(size: 11))
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

    static func estimatedHeight(for item: ThreadItem, tileWidth: CGFloat) -> CGFloat {
        tileWidth * ThreadItemImageSizing.heightRatio(for: item) + 78
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
            .environmentObject(AppState())
    }
}
