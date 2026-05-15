//
//  LocalThreadRepository.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

final class LocalThreadRepository: ThreadRepository {
    // Local demo data stays behind the repository boundary so AppState can swap
    // to a remote Supabase-backed repository later without changing view/state code.
    private var currentUser: UserProfile
    private var users: [UserProfile]
    private var threadItems: [ThreadItem]
    private var borrowRequests: [BorrowRequest]
    private var messages: [DMMessage]
    private var friendRequestState: FriendRequestState

    init(
        currentUser: UserProfile = SampleData.currentUser,
        users: [UserProfile] = SampleData.users,
        threadItems: [ThreadItem] = SampleData.threadItems,
        borrowRequests: [BorrowRequest] = SampleData.borrowRequests,
        messages: [DMMessage] = SampleData.dmMessages,
        friendRequestState: FriendRequestState = FriendRequestState(incomingUserIDs: [SampleData.users[5].id])
    ) {
        self.currentUser = currentUser
        self.users = users
        self.threadItems = threadItems
        self.borrowRequests = borrowRequests
        self.messages = messages
        self.friendRequestState = friendRequestState
    }

    func fetchCurrentUser() async throws -> UserProfile {
        currentUser
    }

    func fetchUsers() async throws -> [UserProfile] {
        users
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        threadItems
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        borrowRequests
    }

    func fetchMessages() async throws -> [DMMessage] {
        messages
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        friendRequestState
    }

    func saveUser(_ user: UserProfile) async throws {
        if user.id == currentUser.id {
            currentUser = user
        }

        upsert(user, in: &users)
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        upsert(item, in: &threadItems)
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        upsert(request, in: &borrowRequests)
    }

    func saveMessage(_ message: DMMessage) async throws {
        upsert(message, in: &messages)
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        friendRequestState = state
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        threadItems.removeAll { $0.id == itemID }
        borrowRequests.removeAll { $0.itemID == itemID }
    }

    func setItemLiked(_ itemID: ThreadItem.ID, liked: Bool, likedAt: Date?) async throws {
        guard let index = threadItems.firstIndex(where: { $0.id == itemID }) else { return }
        threadItems[index].isLikedByCurrentUser = liked
        threadItems[index].likedAt = likedAt
    }

    func setUserFollowed(_ userID: UserProfile.ID, followed: Bool) async throws {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }
        users[index].isFollowedByCurrentUser = followed
    }

    func sendFriendRequest(to userID: UserProfile.ID) async throws {
        friendRequestState.outgoingUserIDs.insert(userID)
    }

    func cancelFriendRequest(to userID: UserProfile.ID) async throws {
        friendRequestState.outgoingUserIDs.remove(userID)
    }

    func approveFriendRequest(from userID: UserProfile.ID) async throws {
        friendRequestState.incomingUserIDs.remove(userID)
    }

    func denyFriendRequest(from userID: UserProfile.ID) async throws {
        friendRequestState.incomingUserIDs.remove(userID)
    }

    private func upsert<Value: Identifiable>(_ value: Value, in values: inout [Value]) where Value.ID: Equatable {
        if let index = values.firstIndex(where: { $0.id == value.id }) {
            values[index] = value
        } else {
            values.append(value)
        }
    }
}
