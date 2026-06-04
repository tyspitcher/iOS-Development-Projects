//
//  FriendListViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

struct FriendListViewModel {
    let appState: AppState

    func searchResults(matching query: String) -> [UserProfile] {
        appState.potentialFriends(matching: query)
    }

    var friends: [UserProfile] {
        appState.friends
    }

    var requestedFriends: [UserProfile] {
        appState.requestedFriends
    }

    var incomingFriendRequests: [UserProfile] {
        appState.incomingFriendRequests
    }

    var incomingFollowRequests: [UserProfile] {
        appState.incomingFollowRequests
    }

    func requestSentMessage(for user: UserProfile) -> String {
        "Request sent to \(user.displayName). They'll be added once approved."
    }

    func isCurrentUserProfile(_ user: UserProfile) -> Bool {
        appState.isCurrentUser(id: user.id)
    }

    func canViewCloset(for user: UserProfile) -> Bool {
        isCurrentUserProfile(user) || user.relationship == .friend || user.visibility == .publicProfile
    }

    func visibleFriendRequests(on profile: UserProfile) -> [UserProfile] {
        appState.visibleFriendRequests(on: profile)
    }

    func connectionState(for user: UserProfile) -> FriendConnectionState {
        appState.friendConnectionState(for: user.id)
    }

    func followConnectionState(for user: UserProfile) -> FollowConnectionState {
        appState.followConnectionState(for: user.id)
    }

    func followStatusTitle(for user: UserProfile) -> String {
        switch followConnectionState(for: user) {
        case .follow:
            return "Follow"
        case .requested:
            return "Follow Requested"
        case .following:
            return "Following"
        }
    }

    func followStatusIcon(for user: UserProfile) -> String {
        switch followConnectionState(for: user) {
        case .follow:
            return "plus.circle"
        case .requested:
            return "clock.fill"
        case .following:
            return "checkmark.circle.fill"
        }
    }

    func statusTitle(for user: UserProfile) -> String {
        switch connectionState(for: user) {
        case .addFriend:
            return "Add Friend"
        case .requested:
            return "Requested"
        case .incomingRequest:
            return "Incoming Request"
        case .friends:
            return "Friends"
        }
    }

    func statusIcon(for user: UserProfile) -> String {
        switch connectionState(for: user) {
        case .addFriend:
            return "person.badge.plus"
        case .requested:
            return "clock.fill"
        case .incomingRequest:
            return "tray.fill"
        case .friends:
            return "person.2.fill"
        }
    }

    func relationshipActionTitle(for user: UserProfile) -> String {
        switch connectionState(for: user) {
        case .friends:
            return "Friends"
        case .requested:
            return "Requested"
        case .incomingRequest:
            return "Incoming Request"
        case .addFriend:
            return "Request Friend"
        }
    }
}
