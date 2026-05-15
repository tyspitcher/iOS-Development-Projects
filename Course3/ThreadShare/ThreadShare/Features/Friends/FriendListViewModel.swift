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

    func relationshipActionTitle(for user: UserProfile) -> String {
        if user.relationship == .friend {
            return "Friends"
        } else if appState.hasSentFriendRequest(to: user.id) {
            return "Request Sent"
        } else if appState.hasIncomingFriendRequest(from: user.id) {
            return "Respond"
        } else {
            return "Request Friend"
        }
    }
}
