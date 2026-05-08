//
//  ThreadRepository.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

// Main data abstraction for ThreadShare. Views and AppState should depend on
// this protocol, not on SampleData, Firestore, or any concrete storage layer.
// When Firebase Auth is added, the signed-in user's UID should be resolved in
// the repository implementation and mapped into ThreadShare's user/request IDs.
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
    func saveFriendRequestState(_ state: FriendRequestState) async throws
    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws
}
