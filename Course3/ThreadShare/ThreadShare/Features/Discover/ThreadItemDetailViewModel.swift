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

    var comments: [ThreadItemComment] {
        appState.comments(for: currentItem.id)
    }

    var viewerRelationship: UserRelationship {
        owner?.relationship ?? .publicUser
    }

    var friendConnectionState: FriendConnectionState {
        guard let owner else { return .addFriend }
        return appState.friendConnectionState(for: owner.id)
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

    var canBlockOwner: Bool {
        guard let owner else { return false }
        return appState.canBlockUser(owner.id)
    }

    var canOwnerToggleAvailability: Bool {
        isOwnedByCurrentUser && [.available, .notAvailable].contains(currentItem.availabilityStatus)
    }

    var availabilityToggleTitle: String {
        currentItem.availabilityStatus == .available ? "Mark Unavailable" : "Mark Available"
    }

    var availabilityToggleIcon: String {
        currentItem.availabilityStatus == .available ? "eye.slash.fill" : "checkmark.circle.fill"
    }

    var availabilityHelperText: String {
        switch currentItem.availabilityStatus {
        case .available:
            return "Hide this item from borrowing until you are ready to lend it again."
        case .notAvailable:
            return "Bring this item back into your available closet when it is ready to borrow."
        case .requested:
            return "This item has a pending borrow request and cannot be manually changed right now."
        case .borrowed:
            return "This item is currently borrowed and will become available again when it is returned."
        }
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
        guard let owner, friendConnectionState == .addFriend else { return }
        appState.requestFriend(for: owner.id)
    }

    @discardableResult
    func blockOwner() -> Bool {
        guard let owner else { return false }
        return appState.blockUser(owner.id)
    }

    func canDeleteComment(_ comment: ThreadItemComment) -> Bool {
        appState.canDeleteComment(comment)
    }

    func author(for comment: ThreadItemComment) -> UserProfile? {
        appState.author(for: comment)
    }

    @discardableResult
    func addComment(body: String) -> ThreadItemComment? {
        appState.addComment(to: currentItem.id, body: body)
    }

    @discardableResult
    func deleteComment(_ commentID: ThreadItemComment.ID) -> Bool {
        appState.deleteComment(commentID)
    }

    func formattedCreatedDate(for comment: ThreadItemComment) -> String {
        Self.commentDateFormatter.string(from: comment.createdAt)
    }

    func deleteItem() -> Bool {
        appState.deleteThreadItem(currentItem.id)
    }

    @discardableResult
    func toggleOwnedAvailability() -> Bool {
        let nextStatus: ItemAvailabilityStatus = currentItem.availabilityStatus == .available
            ? .notAvailable
            : .available
        return appState.updateOwnedItemAvailability(itemID: currentItem.id, status: nextStatus)
    }

    private static let commentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
