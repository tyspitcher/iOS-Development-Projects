//
//  ProfileConnectionsManagementView.swift
//  ThreadShare
//
//  Created by Codex on 6/3/26.
//

import SwiftUI

struct ProfileConnectionsManagementView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var connections: [UserProfile] = []
    @State private var isLoading = true
    @State private var pendingRemoval: UserProfile?

    let kind: ProfileConnectionsSheet

    private var currentUserID: UserProfile.ID? {
        appState.currentUser?.id
    }

    private var title: String {
        kind.displayName
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(AppTheme.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if connections.isEmpty {
                    EmptyStateView(
                        title: kind.emptyTitle,
                        message: kind.emptyMessage,
                        systemImage: kind.emptySystemImage
                    )
                    .padding(AppTheme.pagePadding)
                } else {
                    List {
                        ForEach(connections) { user in
                            NavigationLink {
                                UserProfileDetailView(user: user)
                            } label: {
                                ProfileConnectionRow(
                                    user: user,
                                    subtitle: kind.rowSubtitle
                                )
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if kind.allowsRemoval {
                                    Button(role: .destructive) {
                                        pendingRemoval = user
                                    } label: {
                                        Label(kind.removeActionTitle, systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.background)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task(id: currentUserID) {
                await loadConnections()
            }
            .alert(item: $pendingRemoval) { user in
                Alert(
                    title: Text(kind.confirmationTitle(for: user)),
                    message: Text(kind.confirmationMessage(for: user)),
                    primaryButton: .destructive(Text(kind.confirmationActionTitle)) {
                        Task {
                            await removeConnection(user)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    @MainActor
    private func loadConnections() async {
        guard let currentUserID else {
            connections = []
            isLoading = false
            return
        }

        isLoading = true
        defer { isLoading = false }

        switch kind {
        case .friends:
            connections = appState.friends
        case .followers:
            connections = await appState.followerUsers(for: currentUserID)
        case .following:
            connections = appState.followingUsers(for: currentUserID)
        }
    }

    @MainActor
    private func removeConnection(_ user: UserProfile) async {
        let didChange: Bool
        switch kind {
        case .friends:
            didChange = appState.removeFriend(user.id)
        case .followers:
            didChange = appState.removeFollower(user.id)
        case .following:
            didChange = appState.unfollow(user.id)
        }

        if didChange {
            connections.removeAll { $0.id == user.id }
        }
    }
}

private struct ProfileConnectionRow: View {
    let user: UserProfile
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(imageName: user.avatarImageName, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(user.displayName)
                    .font(AppTheme.bodyFont(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text("@\(user.username)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(1)
            }

            Spacer()

            Text(subtitle)
                .font(AppTheme.bodyFont(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.mutedInk)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

extension ProfileConnectionsSheet {
    var displayName: String {
        switch self {
        case .friends:
            "Friends"
        case .followers:
            "Followers"
        case .following:
            "Following"
        }
    }

    var rowSubtitle: String {
        switch self {
        case .friends:
            "Friend"
        case .followers:
            "Follows you"
        case .following:
            "You follow"
        }
    }

    var emptyTitle: String {
        switch self {
        case .friends:
            "No friends yet"
        case .followers:
            "No followers yet"
        case .following:
            "Not following anyone"
        }
    }

    var emptyMessage: String {
        switch self {
        case .friends:
            "Friends will appear here once connections are approved."
        case .followers:
            "People who follow this profile will appear here."
        case .following:
            "People this profile follows will appear here."
        }
    }

    var emptySystemImage: String {
        switch self {
        case .friends:
            "person.2.fill"
        case .followers:
            "person.2"
        case .following:
            "person.crop.circle.badge.plus"
        }
    }

    var removeActionTitle: String {
        switch self {
        case .friends:
            "Unfriend"
        case .followers:
            "Remove"
        case .following:
            "Unfollow"
        }
    }

    var allowsRemoval: Bool {
        switch self {
        case .friends, .followers, .following:
            true
        }
    }

    func confirmationTitle(for user: UserProfile) -> String {
        switch self {
        case .friends:
            "Unfriend \(user.displayName)?"
        case .followers:
            "Remove \(user.displayName)?"
        case .following:
            "Unfollow \(user.displayName)?"
        }
    }

    func confirmationMessage(for user: UserProfile) -> String {
        switch self {
        case .friends:
            "This will remove \(user.displayName) from your friends list."
        case .followers:
            "This will remove \(user.displayName) from the follower list for your profile."
        case .following:
            "This will stop you from following \(user.displayName)."
        }
    }

    var confirmationActionTitle: String {
        switch self {
        case .friends:
            "Unfriend"
        case .followers:
            "Remove"
        case .following:
            "Unfollow"
        }
    }
}
