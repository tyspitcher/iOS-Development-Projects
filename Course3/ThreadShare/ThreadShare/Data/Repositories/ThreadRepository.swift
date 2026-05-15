//
//  ThreadRepository.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

// Main data abstraction for ThreadShare. Views and app state should depend on
// this protocol, not on SampleData or any concrete storage layer.
// Future Supabase auth should resolve the signed-in user's identity inside the
// repository implementation and map it into ThreadShare's user/request IDs.
@MainActor
protocol ThreadRepository {
    func fetchCurrentUser() async throws -> UserProfile
    func fetchUsers() async throws -> [UserProfile]
    func fetchThreadItems() async throws -> [ThreadItem]
    func fetchBorrowRequests() async throws -> [BorrowRequest]
    func fetchMessages() async throws -> [DMMessage]
    func fetchFriendRequestState() async throws -> FriendRequestState

    func saveUser(_ user: UserProfile) async throws
    func saveThreadItem(_ item: ThreadItem) async throws
    func saveBorrowRequest(_ request: BorrowRequest) async throws
    func saveMessage(_ message: DMMessage) async throws
    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws

    func setItemLiked(_ itemID: ThreadItem.ID, liked: Bool, likedAt: Date?) async throws
    func setUserFollowed(_ userID: UserProfile.ID, followed: Bool) async throws

    func sendFriendRequest(to userID: UserProfile.ID) async throws
    func cancelFriendRequest(to userID: UserProfile.ID) async throws
    func approveFriendRequest(from userID: UserProfile.ID) async throws
    func denyFriendRequest(from userID: UserProfile.ID) async throws
}
