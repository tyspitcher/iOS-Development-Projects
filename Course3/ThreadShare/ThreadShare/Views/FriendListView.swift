//
//  FriendListView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var requestMessage: String?

    var body: some View {
        List {
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
                if appState.friends.isEmpty {
                    Text("No friends yet.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                } else {
                    ForEach(appState.friends) { friend in
                        NavigationLink {
                            UserProfileDetailView(user: friend)
                        } label: {
                            FriendRow(user: friend)
                        }
                    }
                }
            }
            
            Section("Requested") {
                if appState.requestedFriends.isEmpty {
                    Text("No pending requests sent.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                } else {
                    ForEach(appState.requestedFriends) { user in
                        NavigationLink {
                            UserProfileDetailView(user: user)
                        } label: {
                            HStack(spacing: 12) {
                                FriendRow(user: user)
                                Spacer(minLength: 0)
                                FriendStatusPill(title: "Requested", systemImage: "clock.fill")
                            }
                        }
                    }
                }
            }
            
            Section("Friend Requests") {
                if appState.incomingFriendRequests.isEmpty {
                    Text("No incoming friend requests.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                } else {
                    ForEach(appState.incomingFriendRequests) { user in
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
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Friends")
        .alert("Friend Request Sent", isPresented: Binding(
            get: { requestMessage != nil },
            set: { if !$0 { requestMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(requestMessage ?? "")
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        let potentialFriends = appState.potentialFriends(matching: searchText)

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

                        Button {
                            appState.sendFriendRequest(to: user.id)
                            requestMessage = "Request sent to \(user.displayName). They'll be added once approved."
                        } label: {
                            Label("Add", systemImage: "person.badge.plus")
                                .font(AppTheme.bodyFont(size: 13))
                                .foregroundStyle(AppTheme.accent)
                                .padding(.horizontal, 11)
                                .frame(height: 34)
                                .background(AppTheme.accentSoft, in: Capsule())
                        }
                        .buttonStyle(.plain)
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
    let user: UserProfile

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var isCurrentUserProfile: Bool {
        appState.isCurrentUser(id: user.id)
    }
    
    private var canViewCloset: Bool {
        isCurrentUserProfile || user.relationship == .friend || user.visibility == .publicProfile
    }

    private var profileFriendRequests: [UserProfile] {
        appState.visibleFriendRequests(on: user)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    UserAvatarView(imageName: user.avatarImageName, size: 82)
                        .overlay(Circle().stroke(AppTheme.surface, lineWidth: 4))
                        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 7)

                    Text(user.displayName)
                        .font(AppTheme.titleFont(size: 30))
                        .foregroundStyle(AppTheme.ink)
                    Text("@\(user.username)")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                    Text(user.bio)
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.ink.opacity(0.85))

                    if !isCurrentUserProfile {
                        profileRelationshipAction
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
                    SectionTitle("\(user.displayName)'s Closet")

                    let items = appState.items(for: user)
                    if items.isEmpty {
                        EmptyStateView(
                            title: "No closet items yet",
                            message: "This user has not posted any pieces.",
                            systemImage: "hanger"
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(items) { item in
                                NavigationLink {
                                    ThreadItemDetailView(item: item)
                                } label: {
                                    FriendClosetTile(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var profileRelationshipAction: some View {
        if user.relationship == .friend {
            FriendStatusPill(title: "Friends", systemImage: "person.2.fill")
        } else if appState.hasSentFriendRequest(to: user.id) {
            FriendStatusPill(title: "Request Sent", systemImage: "clock.fill")
        } else if appState.hasIncomingFriendRequest(from: user.id) {
            HStack(spacing: 10) {
                SecondaryButton(title: "Decline", systemImage: "xmark") {
                    appState.denyFriendRequest(from: user.id)
                }
                PrimaryButton(title: "Approve", systemImage: "checkmark") {
                    appState.approveFriendRequest(from: user.id)
                }
            }
        } else {
            PrimaryButton(title: "Request Friend", systemImage: "person.badge.plus") {
                appState.sendFriendRequest(to: user.id)
            }
        }
    }
}

private struct FriendClosetTile: View {
    let item: ThreadItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TileImageFallback(item: item)
                .aspectRatio(1 / ThreadItemImageSizing.heightRatio(for: item), contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(item.title)
                .font(AppTheme.bodyFont(size: 14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)

            HStack {
                Text(item.brand)
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(1)

                Spacer()

                AvailabilityBadge(status: item.availabilityStatus)
            }
        }
        .padding(10)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}
