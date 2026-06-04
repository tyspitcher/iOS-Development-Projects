//
//  ProfileViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

struct ProfileStats {
    let closetItems: Int
    let friends: Int
    let followers: Int
    let following: Int
    let availableToLend: Int
}

struct ProfileViewModel {
    let appState: AppState

    var currentUser: UserProfile? {
        appState.currentUser
    }

    var friendCount: Int {
        appState.friends.count
    }

    var incomingFriendRequestCount: Int {
        appState.incomingFriendRequests.count
    }

    var incomingFollowRequestCount: Int {
        appState.incomingFollowRequests.count
    }

    var requestedFriendCount: Int {
        appState.requestedFriends.count
    }

    var requestedFollowCount: Int {
        appState.requestedFollows.count
    }

    var totalIncomingRequestCount: Int {
        incomingFriendRequestCount + incomingFollowRequestCount
    }

    var unreadNotificationCount: Int {
        appState.unreadNotificationCount
    }

    func closetItems(for user: UserProfile) -> [ThreadItem] {
        appState.items(for: user)
    }

    func likedItems(filter: LikedItemsFilter) -> [ThreadItem] {
        appState.likedItems(filter: filter)
    }

    func stats(for user: UserProfile) -> ProfileStats {
        let items = closetItems(for: user)
        let availableCount = items.filter { $0.availabilityStatus == .available }.count

        return ProfileStats(
            closetItems: items.count,
            friends: friendCount,
            followers: user.followerCount,
            following: user.followingCount,
            availableToLend: availableCount
        )
    }

    func likedDateLabel(for item: ThreadItem) -> String {
        guard let likedAt = item.likedAt else { return "Liked date unavailable" }
        return "Liked \(likedAt.formatted(date: .abbreviated, time: .omitted))"
    }
}
