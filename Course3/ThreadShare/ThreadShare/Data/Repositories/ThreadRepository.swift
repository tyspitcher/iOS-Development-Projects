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
    func fetchItemComments() async throws -> [ThreadItemComment]
    func fetchBorrowRequests() async throws -> [BorrowRequest]
    func fetchMessages() async throws -> [DMMessage]
    func fetchFriendRequestState() async throws -> FriendRequestState
    func fetchFollowRequestState() async throws -> FollowRequestState
    func fetchPendingAccountDeletionRequest() async throws -> AccountDeletionRequest?
    func fetchImmediateAccountDeletionNotice() async throws -> ImmediateAccountDeletionNotice?
    func fetchBlockedUserIDs() async throws -> Set<UserProfile.ID>
    func fetchFollowerUserIDs(for userID: UserProfile.ID) async throws -> Set<UserProfile.ID>
    func fetchNotifications() async throws -> [ThreadNotification]
    func fetchNotificationPreferences() async throws -> ThreadNotificationPreferences?
    func fetchNotificationPreferences(for userID: UserProfile.ID) async throws -> ThreadNotificationPreferences?
    func fetchReturnReminders() async throws -> [BorrowReturnReminder]

    func saveUser(_ user: UserProfile) async throws
    func saveThreadItem(_ item: ThreadItem) async throws
    func saveThreadItemImageData(_ data: Data, for item: ThreadItem) async throws -> String
    func deleteThreadItemImage(at path: String) async throws
    func saveItemComment(_ comment: ThreadItemComment) async throws
    func saveBorrowRequest(_ request: BorrowRequest) async throws
    func saveMessage(_ message: DMMessage) async throws
    func saveItemReport(_ report: ItemReport) async throws
    func saveNotification(_ notification: ThreadNotification) async throws
    func dispatchPushNotification(_ notificationID: ThreadNotification.ID) async throws
    func saveNotificationPreferences(_ preferences: ThreadNotificationPreferences) async throws
    func saveReturnReminder(_ reminder: BorrowReturnReminder) async throws
    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws
    func deleteItemComment(_ commentID: ThreadItemComment.ID) async throws
    func requestAccountDeletion(for userID: UserProfile.ID) async throws -> AccountDeletionRequest
    func requestImmediateAccountDeletion(
        for userID: UserProfile.ID,
        confirmationStatement: String
    ) async throws -> ImmediateAccountDeletionNotice
    func cancelAccountDeletion(for userID: UserProfile.ID) async throws
    func blockUser(_ userID: UserProfile.ID) async throws
    func unblockUser(_ userID: UserProfile.ID) async throws
    func removeFollower(_ followerID: UserProfile.ID, from followedUserID: UserProfile.ID) async throws
    func updateCurrentUserActivity(lastActiveAt: Date) async throws
    func markMessagesRead(from senderID: UserProfile.ID, to recipientID: UserProfile.ID) async throws
    func markNotificationRead(_ notificationID: ThreadNotification.ID, readAt: Date) async throws
    func markAllNotificationsRead(readAt: Date) async throws

    func setItemLiked(_ itemID: ThreadItem.ID, liked: Bool, likedAt: Date?) async throws
    func setUserFollowed(_ userID: UserProfile.ID, followed: Bool) async throws

    func requestFollow(to userID: UserProfile.ID) async throws
    func cancelFollowRequest(to userID: UserProfile.ID) async throws
    func approveFollowRequest(from userID: UserProfile.ID) async throws
    func denyFollowRequest(from userID: UserProfile.ID) async throws
    func sendFriendRequest(to userID: UserProfile.ID) async throws
    func cancelFriendRequest(to userID: UserProfile.ID) async throws
    func approveFriendRequest(from userID: UserProfile.ID) async throws
    func denyFriendRequest(from userID: UserProfile.ID) async throws
}
