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
    private var itemComments: [ThreadItemComment]
    private var borrowRequests: [BorrowRequest]
    private var messages: [DMMessage]
    private var friendRequestState: FriendRequestState
    private var followRequestState: FollowRequestState
    private var pendingDeletionRequests: [UserProfile.ID: AccountDeletionRequest]
    private var immediateDeletionNotices: [UserProfile.ID: ImmediateAccountDeletionNotice]
    private var blockedUserIDs: Set<UserProfile.ID>
    private var itemReports: [ItemReport]
    private var notifications: [ThreadNotification]
    private var notificationPreferences: ThreadNotificationPreferences?
    private var returnReminders: [BorrowReturnReminder]

    init(
        currentUser: UserProfile = SampleData.currentUser,
        users: [UserProfile] = SampleData.users,
        threadItems: [ThreadItem] = SampleData.threadItems,
        itemComments: [ThreadItemComment] = SampleData.itemComments,
        borrowRequests: [BorrowRequest] = SampleData.borrowRequests,
        messages: [DMMessage] = SampleData.dmMessages,
        friendRequestState: FriendRequestState = FriendRequestState(incomingUserIDs: [SampleData.users[5].id]),
        followRequestState: FollowRequestState = FollowRequestState(incomingUserIDs: [SampleData.users[2].id]),
        pendingDeletionRequests: [UserProfile.ID: AccountDeletionRequest] = [:],
        immediateDeletionNotices: [UserProfile.ID: ImmediateAccountDeletionNotice] = [:],
        blockedUserIDs: Set<UserProfile.ID> = [],
        itemReports: [ItemReport] = [],
        notifications: [ThreadNotification] = SampleData.notifications,
        notificationPreferences: ThreadNotificationPreferences? = nil,
        returnReminders: [BorrowReturnReminder] = []
    ) {
        self.currentUser = currentUser
        self.users = users
        self.threadItems = threadItems
        self.itemComments = itemComments
        self.borrowRequests = borrowRequests
        self.messages = messages
        self.friendRequestState = friendRequestState
        self.followRequestState = followRequestState
        self.pendingDeletionRequests = pendingDeletionRequests
        self.immediateDeletionNotices = immediateDeletionNotices
        self.blockedUserIDs = blockedUserIDs
        self.itemReports = itemReports
        self.notifications = notifications
        self.notificationPreferences = notificationPreferences
        self.returnReminders = returnReminders
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

    func fetchItemComments() async throws -> [ThreadItemComment] {
        itemComments
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

    func fetchFollowRequestState() async throws -> FollowRequestState {
        followRequestState
    }

    func fetchPendingAccountDeletionRequest() async throws -> AccountDeletionRequest? {
        guard let request = pendingDeletionRequests[currentUser.id] else { return nil }
        return request.status == .pending ? request : nil
    }

    func fetchImmediateAccountDeletionNotice() async throws -> ImmediateAccountDeletionNotice? {
        immediateDeletionNotices[currentUser.id]
    }

    func fetchBlockedUserIDs() async throws -> Set<UserProfile.ID> {
        blockedUserIDs
    }

    func fetchFollowerUserIDs(for userID: UserProfile.ID) async throws -> Set<UserProfile.ID> {
        guard userID == currentUser.id else { return [] }
        return []
    }

    func fetchNotifications() async throws -> [ThreadNotification] {
        notifications.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchNotificationPreferences() async throws -> ThreadNotificationPreferences? {
        notificationPreferences ?? ThreadNotificationPreferences(userID: currentUser.id)
    }

    func fetchNotificationPreferences(for userID: UserProfile.ID) async throws -> ThreadNotificationPreferences? {
        if userID == currentUser.id {
            return notificationPreferences ?? ThreadNotificationPreferences(userID: currentUser.id)
        }

        return ThreadNotificationPreferences(userID: userID)
    }

    func fetchReturnReminders() async throws -> [BorrowReturnReminder] {
        returnReminders
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

    func saveThreadItemImageData(_ data: Data, for item: ThreadItem) async throws -> String {
        try ThreadItemImageStore.saveImageData(data)
    }

    func deleteThreadItemImage(at path: String) async throws {
        try ThreadItemImageStore.deleteImage(named: path)
    }

    func saveItemComment(_ comment: ThreadItemComment) async throws {
        upsert(comment, in: &itemComments)
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        upsert(request, in: &borrowRequests)
    }

    func saveMessage(_ message: DMMessage) async throws {
        upsert(message, in: &messages)
    }

    func saveItemReport(_ report: ItemReport) async throws {
        upsert(report, in: &itemReports)
    }

    func saveNotification(_ notification: ThreadNotification) async throws {
        upsert(notification, in: &notifications)
    }

    func dispatchPushNotification(_ notificationID: ThreadNotification.ID) async throws {
        // Demo/local mode does not call cloud push infrastructure.
    }

    func saveNotificationPreferences(_ preferences: ThreadNotificationPreferences) async throws {
        notificationPreferences = preferences
    }

    func saveReturnReminder(_ reminder: BorrowReturnReminder) async throws {
        upsert(reminder, in: &returnReminders)
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        friendRequestState = state
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        threadItems.removeAll { $0.id == itemID }
        itemComments.removeAll { $0.itemID == itemID }
        borrowRequests.removeAll { $0.itemID == itemID }
    }

    func deleteItemComment(_ commentID: ThreadItemComment.ID) async throws {
        itemComments.removeAll { $0.id == commentID }
    }

    func requestAccountDeletion(for userID: UserProfile.ID) async throws -> AccountDeletionRequest {
        let request = AccountDeletionRequest(userID: userID)
        pendingDeletionRequests[userID] = request
        return request
    }

    func requestImmediateAccountDeletion(
        for userID: UserProfile.ID,
        confirmationStatement: String
    ) async throws -> ImmediateAccountDeletionNotice {
        let notice = ImmediateAccountDeletionNotice(
            userID: userID,
            confirmationStatement: confirmationStatement,
            backendRequirementMessage: "Immediate permanent deletion still needs a trusted server-side delete function. Your account remains active until that backend work is completed."
        )
        immediateDeletionNotices[userID] = notice
        return notice
    }

    func cancelAccountDeletion(for userID: UserProfile.ID) async throws {
        guard var request = pendingDeletionRequests[userID] else { return }
        request.status = .canceled
        request.canceledAt = Date()
        pendingDeletionRequests[userID] = request
    }

    func blockUser(_ userID: UserProfile.ID) async throws {
        blockedUserIDs.insert(userID)
    }

    func unblockUser(_ userID: UserProfile.ID) async throws {
        blockedUserIDs.remove(userID)
    }

    func removeFollower(_ followerID: UserProfile.ID, from followedUserID: UserProfile.ID) async throws {
        // Demo mode does not persist follower graph mutations.
    }

    func updateCurrentUserActivity(lastActiveAt: Date) async throws {
        // Demo mode keeps activity local and ephemeral.
    }

    func markMessagesRead(from senderID: UserProfile.ID, to recipientID: UserProfile.ID) async throws {
        for index in messages.indices {
            if messages[index].senderID == senderID, messages[index].recipientID == recipientID {
                messages[index].isRead = true
            }
        }
    }

    func markNotificationRead(_ notificationID: ThreadNotification.ID, readAt: Date) async throws {
        guard let index = notifications.firstIndex(where: { $0.id == notificationID }) else { return }
        notifications[index].readAt = readAt
    }

    func markAllNotificationsRead(readAt: Date) async throws {
        for index in notifications.indices {
            notifications[index].readAt = notifications[index].readAt ?? readAt
        }
    }

    func setItemLiked(_ itemID: ThreadItem.ID, liked: Bool, likedAt: Date?) async throws {
        guard let index = threadItems.firstIndex(where: { $0.id == itemID }) else { return }
        let wasLiked = threadItems[index].isLikedByCurrentUser
        threadItems[index].isLikedByCurrentUser = liked
        threadItems[index].likedAt = likedAt
        if wasLiked != liked {
            threadItems[index].likesCount = max(0, threadItems[index].likesCount + (liked ? 1 : -1))
        }
    }

    func setUserFollowed(_ userID: UserProfile.ID, followed: Bool) async throws {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }
        users[index].isFollowedByCurrentUser = followed
    }

    func requestFollow(to userID: UserProfile.ID) async throws {
        followRequestState.outgoingUserIDs.insert(userID)
    }

    func cancelFollowRequest(to userID: UserProfile.ID) async throws {
        followRequestState.outgoingUserIDs.remove(userID)
    }

    func approveFollowRequest(from userID: UserProfile.ID) async throws {
        followRequestState.incomingUserIDs.remove(userID)
    }

    func denyFollowRequest(from userID: UserProfile.ID) async throws {
        followRequestState.incomingUserIDs.remove(userID)
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
