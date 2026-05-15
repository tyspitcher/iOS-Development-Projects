//
//  ThreadItemDetailViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

struct ThreadItemDetailViewModel {
    let appState: AppState
    let item: ThreadItem

    var currentItem: ThreadItem {
        appState.threadItems.first { $0.id == item.id } ?? item
    }

    var owner: UserProfile? {
        appState.owner(for: currentItem)
    }

    var viewerRelationship: UserRelationship {
        owner?.relationship ?? .publicUser
    }

    var isOwnedByCurrentUser: Bool {
        appState.isCurrentUser(id: currentItem.ownerID)
    }

    var canRequestBorrow: Bool {
        !isOwnedByCurrentUser && viewerRelationship == .friend && currentItem.availabilityStatus == .available
    }

    var shouldShowConnectionActions: Bool {
        guard !isOwnedByCurrentUser, owner != nil else { return false }
        return true
    }

    var borrowMessage: String {
        if viewerRelationship != .friend {
            return "Add as friend to request borrowing"
        }

        return currentItem.availabilityStatus.displayName
    }

    var shopButtonTitle: String {
        "Buy Now Online"
    }

    var shopButtonSubtitle: String {
        "Open the original listing from \(currentItem.wherePurchased)."
    }

    func toggleLike() {
        appState.toggleLike(for: currentItem.id)
    }

    func followOwnerIfNeeded() {
        guard let owner, !owner.isFollowedByCurrentUser else { return }
        appState.toggleFollow(for: owner.id)
    }

    func requestFriendIfNeeded() {
        guard let owner, owner.relationship != .friend else { return }
        appState.requestFriend(for: owner.id)
    }

    func deleteItem() -> Bool {
        appState.deleteThreadItem(currentItem.id)
    }
}
