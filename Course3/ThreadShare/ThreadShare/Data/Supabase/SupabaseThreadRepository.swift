//
//  SupabaseThreadRepository.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum SupabaseThreadRepositoryError: Error {
    case notAuthenticated
    case invalidDate
}

@MainActor
final class SupabaseThreadRepository: ThreadRepository {
    private let client: SupabaseHTTPClient
    private let sessionProvider: SupabaseSessionProviding
    private let immediateDeletionNoticeStore: ImmediateAccountDeletionNoticeStore
    private let storageService: SupabaseStorageService
    private let notificationDispatchService: SupabaseNotificationDispatchService

    init(
        sessionProvider: SupabaseSessionProviding
    ) {
        self.sessionProvider = sessionProvider
        self.client = SupabaseHTTPClient(sessionProvider: sessionProvider)
        self.immediateDeletionNoticeStore = ImmediateAccountDeletionNoticeStore()
        self.storageService = SupabaseStorageService(sessionProvider: sessionProvider)
        self.notificationDispatchService = SupabaseNotificationDispatchService(sessionProvider: sessionProvider)
    }

    func fetchCurrentUser() async throws -> UserProfile {
        let session = try requireSession()
        let rows: [SupabaseProfileRow] = try await client.request(
            path: "/rest/v1/profiles",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "id", value: "eq.\(session.userID.uuidString)")
            ]
        )

        guard let row = rows.first else {
            throw SupabaseThreadRepositoryError.notAuthenticated
        }
        return row.toUserProfile(
            relationship: .publicUser,
            isFollowedByCurrentUser: false
        )
    }

    func fetchUsers() async throws -> [UserProfile] {
        let session = try requireSession()
        async let profileRows: [SupabaseProfileRow] = client.request(
            path: "/rest/v1/profiles",
            method: .get,
            queryItems: [URLQueryItem(name: "select", value: "*")]
        )
        async let followRows: [SupabaseFollowRow] = client.request(
            path: "/rest/v1/follows",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "follower_id", value: "eq.\(session.userID.uuidString)")
            ]
        )
        async let friendRows: [SupabaseFriendRequestRow] = client.request(
            path: "/rest/v1/friend_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "or", value: "(requester_id.eq.\(session.userID.uuidString),recipient_id.eq.\(session.userID.uuidString))")
            ]
        )

        let profiles = try await profileRows
        let follows = try await followRows
        let friends = try await friendRows

        let followingIDs = Set(follows.map(\.followed_user_id))
        let friendIDs = Set(friends.compactMap { row -> UUID? in
            guard row.status == "approved" else { return nil }
            return row.requester_id == session.userID ? row.recipient_id : row.requester_id
        })

        return profiles.map { row in
            let relationship: UserRelationship
            if row.id == session.userID {
                relationship = .publicUser
            } else if friendIDs.contains(row.id) {
                relationship = .friend
            } else if followingIDs.contains(row.id) {
                relationship = .follower
            } else {
                relationship = .publicUser
            }
            return row.toUserProfile(
                relationship: relationship,
                isFollowedByCurrentUser: followingIDs.contains(row.id)
            )
        }
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        let session = try requireSession()
        async let itemRows: [SupabaseThreadItemRow] = client.request(
            path: "/rest/v1/thread_items",
            method: .get,
            queryItems: [URLQueryItem(name: "select", value: "*")]
        )
        async let likeRows: [SupabaseLikeRow] = client.request(
            path: "/rest/v1/likes",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)")
            ]
        )

        let rows = try await itemRows
        let likes = try await likeRows
        let likedByCurrentUser = Dictionary(uniqueKeysWithValues: likes.map { ($0.item_id, $0) })

        return rows.map { row in
            row.toThreadItem(
                isLikedByCurrentUser: likedByCurrentUser[row.id] != nil,
                likedAt: likedByCurrentUser[row.id]?.liked_at
            )
        }
    }

    func fetchItemComments() async throws -> [ThreadItemComment] {
        let rows: [SupabaseItemCommentRow] = try await client.request(
            path: "/rest/v1/item_comments",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order", value: "created_at.asc")
            ]
        )
        return rows.map { $0.toThreadItemComment() }
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        let rows: [SupabaseBorrowRequestRow] = try await client.request(
            path: "/rest/v1/borrow_requests",
            method: .get,
            queryItems: [URLQueryItem(name: "select", value: "*")]
        )
        return rows.map { $0.toBorrowRequest() }
    }

    func fetchMessages() async throws -> [DMMessage] {
        let rows: [SupabaseMessageRow] = try await client.request(
            path: "/rest/v1/messages",
            method: .get,
            queryItems: [URLQueryItem(name: "select", value: "*")]
        )
        return rows.map { $0.toDMMessage() }
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        let session = try requireSession()
        let rows: [SupabaseFriendRequestRow] = try await client.request(
            path: "/rest/v1/friend_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "or", value: "(requester_id.eq.\(session.userID.uuidString),recipient_id.eq.\(session.userID.uuidString))"),
                URLQueryItem(name: "status", value: "eq.pending")
            ]
        )

        let outgoing = Set(rows.filter { $0.requester_id == session.userID }.map(\.recipient_id))
        let incoming = Set(rows.filter { $0.recipient_id == session.userID }.map(\.requester_id))
        return FriendRequestState(outgoingUserIDs: outgoing, incomingUserIDs: incoming)
    }

    func fetchPendingAccountDeletionRequest() async throws -> AccountDeletionRequest? {
        let session = try requireSession()
        let rows: [SupabaseAccountDeletionRequestRow] = try await client.request(
            path: "/rest/v1/account_deletion_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "status", value: "eq.pending"),
                URLQueryItem(name: "order", value: "requested_at.desc"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        return rows.first?.toAccountDeletionRequest()
    }

    func fetchImmediateAccountDeletionNotice() async throws -> ImmediateAccountDeletionNotice? {
        let session = try requireSession()
        return immediateDeletionNoticeStore.load(for: session.userID)
    }

    func fetchBlockedUserIDs() async throws -> Set<UserProfile.ID> {
        let session = try requireSession()
        let rows: [SupabaseUserBlockRow] = try await client.request(
            path: "/rest/v1/user_blocks",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "blocker_id", value: "eq.\(session.userID.uuidString)")
            ]
        )
        return Set(rows.map(\.blocked_user_id))
    }

    func fetchNotifications() async throws -> [ThreadNotification] {
        let session = try requireSession()
        let rows: [SupabaseNotificationRow] = try await client.request(
            path: "/rest/v1/notifications",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "recipient_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )
        return rows.map { $0.toThreadNotification() }
    }

    func fetchNotificationPreferences() async throws -> ThreadNotificationPreferences? {
        let session = try requireSession()
        let rows: [SupabaseNotificationPreferencesRow] = try await client.request(
            path: "/rest/v1/notification_preferences",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        return rows.first?.toThreadNotificationPreferences()
    }

    func fetchNotificationPreferences(for userID: UserProfile.ID) async throws -> ThreadNotificationPreferences? {
        let rows: [SupabaseNotificationPreferencesRow] = try await client.request(
            path: "/rest/v1/notification_preferences",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        return rows.first?.toThreadNotificationPreferences()
    }

    func fetchReturnReminders() async throws -> [BorrowReturnReminder] {
        let session = try requireSession()
        let rows: [SupabaseReturnReminderRow] = try await client.request(
            path: "/rest/v1/return_reminders",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)")
            ]
        )
        return rows.map { $0.toBorrowReturnReminder() }
    }

    func saveUser(_ user: UserProfile) async throws {
        let session = try requireSession()
        let existingRows: [SupabaseProfileRow] = try await client.request(
            path: "/rest/v1/profiles",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "email"),
                URLQueryItem(name: "id", value: "eq.\(user.id.uuidString)")
            ]
        )
        let email = existingRows.first?.email ?? session.email
        let row = SupabaseProfileRow(
            id: user.id,
            email: email,
            display_name: user.displayName,
            username: user.username,
            bio: user.bio,
            avatar_bucket: "avatars",
            avatar_path: user.avatarImageName,
            city: user.city,
            visibility: user.visibility.rawValue,
            style_interests: user.styleInterests,
            favorite_brands: user.favoriteBrands,
            color_palette_preference_ids: user.colorPalettePreferenceIDs,
            follower_count: user.followerCount,
            following_count: user.followingCount,
            last_login_at: user.lastLoginAt,
            last_active_at: user.lastActiveAt,
            created_at: Date(),
            updated_at: Date()
        )
        try await upsert(path: "/rest/v1/profiles", row: row)
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        let previousImagePath = try await existingThreadItemImagePath(for: item.id)
        let row = item.toSupabaseRow()
        try await upsert(path: "/rest/v1/thread_items", row: row)
        if
            let previousImagePath,
            previousImagePath != item.imageName,
            previousImagePath.contains("/")
        {
            try? await storageService.deleteThreadItemImage(at: previousImagePath)
        }
    }

    func saveThreadItemImageData(_ data: Data, for item: ThreadItem) async throws -> String {
        try await storageService.uploadThreadItemImage(
            data,
            ownerID: item.ownerID,
            itemID: item.id
        )
    }

    func deleteThreadItemImage(at path: String) async throws {
        guard path.contains("/") else { return }
        try await storageService.deleteThreadItemImage(at: path)
    }

    func saveItemComment(_ comment: ThreadItemComment) async throws {
        try await upsert(path: "/rest/v1/item_comments", row: comment.toSupabaseRow())
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        let row = request.toSupabaseRow()
        try await upsert(path: "/rest/v1/borrow_requests", row: row)
    }

    func saveMessage(_ message: DMMessage) async throws {
        let row = message.toSupabaseRow()
        try await upsert(path: "/rest/v1/messages", row: row)
    }

    func saveItemReport(_ report: ItemReport) async throws {
        try await insert(path: "/rest/v1/reports", row: report.toSupabaseRow())
    }

    func saveNotification(_ notification: ThreadNotification) async throws {
        let data = try JSONEncoder.threadShareSupabase.encode(notification.toSupabaseRow())
        try await client.requestVoid(
            path: "/rest/v1/notifications",
            method: .post,
            body: data,
            includePreferHeader: false
        )
    }

    func dispatchPushNotification(_ notificationID: ThreadNotification.ID) async throws {
        try await notificationDispatchService.dispatchPush(notificationID: notificationID)
    }

    func saveNotificationPreferences(_ preferences: ThreadNotificationPreferences) async throws {
        try await upsert(
            path: "/rest/v1/notification_preferences",
            onConflict: "user_id",
            row: preferences.toSupabaseRow()
        )
    }

    func saveReturnReminder(_ reminder: BorrowReturnReminder) async throws {
        try await upsert(
            path: "/rest/v1/return_reminders",
            onConflict: "user_id,borrow_request_id",
            row: reminder.toSupabaseRow()
        )
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        let imagePath = try await existingThreadItemImagePath(for: itemID)
        try await client.requestVoid(
            path: "/rest/v1/thread_items",
            method: .delete,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(itemID.uuidString)")]
        )
        if let imagePath, imagePath.contains("/") {
            try? await storageService.deleteThreadItemImage(at: imagePath)
        }
    }

    func deleteItemComment(_ commentID: ThreadItemComment.ID) async throws {
        try await client.requestVoid(
            path: "/rest/v1/item_comments",
            method: .delete,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(commentID.uuidString)")]
        )
    }

    func requestAccountDeletion(for userID: UserProfile.ID) async throws -> AccountDeletionRequest {
        let now = Date()
        let request = AccountDeletionRequest(userID: userID, requestedAt: now)
        let row = SupabaseAccountDeletionRequestRow(
            id: UUID(),
            user_id: userID,
            requested_at: now,
            scheduled_deletion_at: request.scheduledDeletionDate,
            canceled_at: nil,
            completed_at: nil,
            status: AccountDeletionRequestStatus.pending.rawValue,
            created_at: now,
            updated_at: now
        )
        try await insert(path: "/rest/v1/account_deletion_requests", row: row)
        return request
    }

    func requestImmediateAccountDeletion(
        for userID: UserProfile.ID,
        confirmationStatement: String
    ) async throws -> ImmediateAccountDeletionNotice {
        let notice = ImmediateAccountDeletionNotice(
            userID: userID,
            confirmationStatement: confirmationStatement,
            backendRequirementMessage: "Immediate permanent deletion still needs a server-side function with service-role access. This build has recorded your confirmation, but your account has not been deleted."
        )
        immediateDeletionNoticeStore.save(notice)
        return notice
    }

    func cancelAccountDeletion(for userID: UserProfile.ID) async throws {
        let existingRows: [SupabaseAccountDeletionRequestRow] = try await client.request(
            path: "/rest/v1/account_deletion_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "status", value: "eq.pending"),
                URLQueryItem(name: "order", value: "requested_at.desc"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        guard var row = existingRows.first else { return }
        row.status = AccountDeletionRequestStatus.canceled.rawValue
        row.canceled_at = Date()
        row.updated_at = Date()
        try await upsert(path: "/rest/v1/account_deletion_requests", row: row)
    }

    func blockUser(_ userID: UserProfile.ID) async throws {
        let session = try requireSession()
        guard userID != session.userID else { return }

        let existingRows: [SupabaseUserBlockRow] = try await client.request(
            path: "/rest/v1/user_blocks",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "blocker_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "blocked_user_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        guard existingRows.isEmpty else { return }

        let row = SupabaseUserBlockRow(
            id: UUID(),
            blocker_id: session.userID,
            blocked_user_id: userID,
            created_at: Date()
        )
        try await insert(path: "/rest/v1/user_blocks", row: row)
    }

    func updateCurrentUserActivity(lastActiveAt: Date) async throws {
        let session = try requireSession()
        try await SupabaseUserActivityService(session: session).markActive(at: lastActiveAt)
    }

    func markMessagesRead(from senderID: UserProfile.ID, to recipientID: UserProfile.ID) async throws {
        let patch = MessageReadPatch(is_read: true)
        let data = try JSONEncoder.threadShareSupabase.encode(patch)
        try await client.requestVoid(
            path: "/rest/v1/messages",
            method: .patch,
            queryItems: [
                URLQueryItem(name: "sender_id", value: "eq.\(senderID.uuidString)"),
                URLQueryItem(name: "recipient_id", value: "eq.\(recipientID.uuidString)"),
                URLQueryItem(name: "is_read", value: "eq.false")
            ],
            body: data,
            includePreferHeader: false
        )
    }

    func markNotificationRead(_ notificationID: ThreadNotification.ID, readAt: Date) async throws {
        let patch = NotificationReadPatch(read_at: readAt)
        let data = try JSONEncoder.threadShareSupabase.encode(patch)
        try await client.requestVoid(
            path: "/rest/v1/notifications",
            method: .patch,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(notificationID.uuidString)")],
            body: data,
            includePreferHeader: false
        )
    }

    func markAllNotificationsRead(readAt: Date) async throws {
        let session = try requireSession()
        let patch = NotificationReadPatch(read_at: readAt)
        let data = try JSONEncoder.threadShareSupabase.encode(patch)
        try await client.requestVoid(
            path: "/rest/v1/notifications",
            method: .patch,
            queryItems: [
                URLQueryItem(name: "recipient_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "read_at", value: "is.null")
            ],
            body: data,
            includePreferHeader: false
        )
    }

    func setItemLiked(_ itemID: ThreadItem.ID, liked: Bool, likedAt: Date?) async throws {
        let session = try requireSession()
        if liked {
            let row = SupabaseLikeRow(id: UUID(), user_id: session.userID, item_id: itemID, liked_at: likedAt ?? Date())
            try await upsert(path: "/rest/v1/likes", row: row)
        } else {
            try await client.requestVoid(
                path: "/rest/v1/likes",
                method: .delete,
                queryItems: [
                    URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)"),
                    URLQueryItem(name: "item_id", value: "eq.\(itemID.uuidString)")
                ]
            )
        }
    }

    func setUserFollowed(_ userID: UserProfile.ID, followed: Bool) async throws {
        let session = try requireSession()
        if followed {
            let row = SupabaseFollowRow(id: UUID(), follower_id: session.userID, followed_user_id: userID, created_at: Date())
            try await upsert(path: "/rest/v1/follows", row: row)
        } else {
            try await client.requestVoid(
                path: "/rest/v1/follows",
                method: .delete,
                queryItems: [
                    URLQueryItem(name: "follower_id", value: "eq.\(session.userID.uuidString)"),
                    URLQueryItem(name: "followed_user_id", value: "eq.\(userID.uuidString)")
                ]
            )
        }
    }

    func sendFriendRequest(to userID: UserProfile.ID) async throws {
        let session = try requireSession()
        let activeRows = try await fetchActiveFriendRows(
            userA: session.userID,
            userB: userID
        )

        if activeRows.contains(where: { $0.status.lowercased() == "approved" }) {
            return
        }

        if activeRows.contains(where: {
            $0.status.lowercased() == "pending" &&
            $0.requester_id == userID &&
            $0.recipient_id == session.userID
        }) {
            try await approveFriendRequest(from: userID)
            return
        }

        if activeRows.contains(where: {
            $0.status.lowercased() == "pending" &&
            $0.requester_id == session.userID &&
            $0.recipient_id == userID
        }) {
            return
        }

        let row = SupabaseFriendRequestRow(
            id: UUID(),
            requester_id: session.userID,
            recipient_id: userID,
            status: "pending",
            created_at: Date(),
            responded_at: nil
        )
        try await insert(path: "/rest/v1/friend_requests", row: row)
    }

    func cancelFriendRequest(to userID: UserProfile.ID) async throws {
        let session = try requireSession()
        try await client.requestVoid(
            path: "/rest/v1/friend_requests",
            method: .delete,
            queryItems: [
                URLQueryItem(name: "requester_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "recipient_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "status", value: "eq.pending")
            ]
        )
    }

    func approveFriendRequest(from userID: UserProfile.ID) async throws {
        let session = try requireSession()
        let rows: [SupabaseFriendRequestRow] = try await client.request(
            path: "/rest/v1/friend_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "requester_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "recipient_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "status", value: "eq.pending")
            ]
        )
        for row in rows {
            var approved = row
            approved.status = "approved"
            approved.responded_at = Date()
            try await upsert(path: "/rest/v1/friend_requests", row: approved)
        }
    }

    func denyFriendRequest(from userID: UserProfile.ID) async throws {
        let session = try requireSession()
        try await client.requestVoid(
            path: "/rest/v1/friend_requests",
            method: .delete,
            queryItems: [
                URLQueryItem(name: "requester_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "recipient_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "status", value: "eq.pending")
            ]
        )
    }

    private func requireSession() throws -> SupabaseSession {
        guard let session = sessionProvider.session else {
            throw SupabaseThreadRepositoryError.notAuthenticated
        }
        return session
    }

    private func upsert<Row: Encodable>(path: String, onConflict: String = "id", row: Row) async throws {
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        try await client.requestVoid(
            path: path,
            method: .post,
            queryItems: [URLQueryItem(name: "on_conflict", value: onConflict)],
            body: data
        )
    }

    private func insert<Row: Encodable>(path: String, row: Row) async throws {
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        try await client.requestVoid(
            path: path,
            method: .post,
            body: data
        )
    }

    private func existingThreadItemImagePath(for itemID: ThreadItem.ID) async throws -> String? {
        let rows: [SupabaseThreadItemImagePathRow] = try await client.request(
            path: "/rest/v1/thread_items",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "image_path"),
                URLQueryItem(name: "id", value: "eq.\(itemID.uuidString)"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )
        return rows.first?.image_path
    }

    private func fetchActiveFriendRows(
        userA: UserProfile.ID,
        userB: UserProfile.ID
    ) async throws -> [SupabaseFriendRequestRow] {
        let rows: [SupabaseFriendRequestRow] = try await client.request(
            path: "/rest/v1/friend_requests",
            method: .get,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(
                    name: "or",
                    value: "(and(requester_id.eq.\(userA.uuidString),recipient_id.eq.\(userB.uuidString)),and(requester_id.eq.\(userB.uuidString),recipient_id.eq.\(userA.uuidString)))"
                ),
                URLQueryItem(name: "status", value: "in.(pending,approved)")
            ]
        )
        return rows
    }
}

private extension SupabaseProfileRow {
    func toUserProfile(
        relationship: UserRelationship,
        isFollowedByCurrentUser: Bool
    ) -> UserProfile {
        UserProfile(
            id: id,
            displayName: display_name,
            username: username,
            bio: bio,
            avatarImageName: avatar_path ?? "person.crop.circle.fill",
            city: city,
            relationship: relationship,
            visibility: ProfileVisibility(rawValue: visibility) ?? .publicProfile,
            followerCount: follower_count,
            followingCount: following_count,
            styleInterests: FashionPreferenceCatalog.normalizedStyleIDs(from: style_interests),
            favoriteBrands: favorite_brands,
            colorPalettePreferenceIDs: FashionPreferenceCatalog.deduplicated(color_palette_preference_ids),
            isFollowedByCurrentUser: isFollowedByCurrentUser,
            lastLoginAt: last_login_at,
            lastActiveAt: last_active_at
        )
    }
}

private extension SupabaseItemCommentRow {
    func toThreadItemComment() -> ThreadItemComment {
        ThreadItemComment(
            id: id,
            itemID: item_id,
            authorID: author_id,
            body: body,
            createdAt: created_at ?? Date()
        )
    }
}

private extension ThreadItemComment {
    func toSupabaseRow() -> SupabaseItemCommentRow {
        SupabaseItemCommentRow(
            id: id,
            item_id: itemID,
            author_id: authorID,
            body: body,
            created_at: createdAt
        )
    }
}

private struct NotificationReadPatch: Encodable {
    let read_at: Date
}

private struct MessageReadPatch: Encodable {
    let is_read: Bool
}

private extension SupabaseNotificationRow {
    func toThreadNotification() -> ThreadNotification {
        ThreadNotification(
            id: id,
            recipientID: recipient_id,
            actorID: actor_id,
            kind: ThreadNotificationKind(rawValue: kind) ?? .borrowRequest,
            title: title,
            body: body,
            itemID: item_id,
            borrowRequestID: borrow_request_id,
            messageID: message_id,
            createdAt: created_at ?? Date(),
            readAt: read_at
        )
    }
}

private extension ThreadNotification {
    func toSupabaseRow() -> SupabaseNotificationRow {
        SupabaseNotificationRow(
            id: id,
            recipient_id: recipientID,
            actor_id: actorID,
            kind: kind.rawValue,
            title: title,
            body: body,
            item_id: itemID,
            borrow_request_id: borrowRequestID,
            message_id: messageID,
            created_at: createdAt,
            read_at: readAt
        )
    }
}

private extension SupabaseNotificationPreferencesRow {
    func toThreadNotificationPreferences() -> ThreadNotificationPreferences {
        ThreadNotificationPreferences(
            userID: user_id,
            friendNewItemAlertsEnabled: friend_new_item_alerts_enabled,
            returnReminderCadence: ReturnReminderCadence(rawValue: return_reminder_cadence) ?? .oneTime,
            pushNotificationsEnabled: push_notifications_enabled,
            pushBorrowRequestsEnabled: push_borrow_requests_enabled,
            pushCommentsEnabled: push_comments_enabled,
            pushMessagesEnabled: push_messages_enabled,
            pushFriendNewItemsEnabled: push_friend_new_items_enabled,
            pushReturnRemindersEnabled: push_return_reminders_enabled
        )
    }
}

private extension ThreadNotificationPreferences {
    func toSupabaseRow() -> SupabaseNotificationPreferencesRow {
        SupabaseNotificationPreferencesRow(
            user_id: userID,
            friend_new_item_alerts_enabled: friendNewItemAlertsEnabled,
            return_reminder_cadence: returnReminderCadence.rawValue,
            push_notifications_enabled: pushNotificationsEnabled,
            push_borrow_requests_enabled: pushBorrowRequestsEnabled,
            push_comments_enabled: pushCommentsEnabled,
            push_messages_enabled: pushMessagesEnabled,
            push_friend_new_items_enabled: pushFriendNewItemsEnabled,
            push_return_reminders_enabled: pushReturnRemindersEnabled,
            created_at: Date(),
            updated_at: Date()
        )
    }
}

private extension SupabaseReturnReminderRow {
    func toBorrowReturnReminder() -> BorrowReturnReminder {
        BorrowReturnReminder(
            id: id,
            userID: user_id,
            borrowRequestID: borrow_request_id,
            cadence: ReturnReminderCadence(rawValue: cadence) ?? .oneTime,
            nextReminderAt: next_reminder_at,
            lastSentAt: last_sent_at,
            isEnabled: is_enabled,
            createdAt: created_at ?? Date(),
            updatedAt: updated_at ?? Date()
        )
    }
}

private extension BorrowReturnReminder {
    func toSupabaseRow() -> SupabaseReturnReminderRow {
        SupabaseReturnReminderRow(
            id: id,
            user_id: userID,
            borrow_request_id: borrowRequestID,
            cadence: cadence.rawValue,
            next_reminder_at: nextReminderAt,
            last_sent_at: lastSentAt,
            is_enabled: isEnabled,
            created_at: createdAt,
            updated_at: updatedAt
        )
    }
}

private extension SupabaseAccountDeletionRequestRow {
    func toAccountDeletionRequest() -> AccountDeletionRequest {
        AccountDeletionRequest(
            userID: user_id,
            requestedAt: requested_at,
            scheduledDeletionDate: scheduled_deletion_at,
            status: AccountDeletionRequestStatus(rawValue: status) ?? .pending,
            canceledAt: canceled_at,
            completedAt: completed_at
        )
    }
}

private extension ItemReport {
    func toSupabaseRow() -> SupabaseItemReportRow {
        SupabaseItemReportRow(
            id: id,
            reporter_id: reporterID,
            item_id: itemID,
            owner_id: ownerID,
            reason: reason.rawValue,
            details: details,
            status: status,
            created_at: createdAt
        )
    }
}

private extension SupabaseThreadItemRow {
    func toThreadItem(isLikedByCurrentUser: Bool, likedAt: Date?) -> ThreadItem {
        ThreadItem(
            id: id,
            ownerID: owner_id,
            title: title,
            brand: brand,
            size: size,
            colorName: color_name,
            category: ClothingCategory(rawValue: category) ?? .tops,
            occasions: occasions.compactMap(OccasionCategory.init(rawValue:)),
            condition: ItemCondition(rawValue: condition) ?? .good,
            availabilityStatus: ItemAvailabilityStatus(rawValue: availability_status) ?? .available,
            imageName: image_path ?? "",
            photoAspectRatio: photo_aspect_ratio,
            notes: notes,
            fitsLike: fits_like,
            wherePurchased: where_purchased,
            purchaseLink: purchase_link.flatMap(URL.init(string:)),
            likesCount: max(0, likes_count),
            isLikedByCurrentUser: isLikedByCurrentUser,
            likedAt: likedAt,
            createdAt: created_at ?? Date()
        )
    }
}

private extension ThreadItem {
    func toSupabaseRow() -> SupabaseThreadItemRow {
        SupabaseThreadItemRow(
            id: id,
            owner_id: ownerID,
            title: title,
            brand: brand,
            size: size,
            color_name: colorName,
            category: category.rawValue,
            occasions: occasions.map(\.rawValue),
            condition: condition.rawValue,
            availability_status: availabilityStatus.rawValue,
            image_bucket: "item-images",
            image_path: imageName,
            photo_aspect_ratio: photoAspectRatio,
            notes: notes,
            fits_like: fitsLike,
            where_purchased: wherePurchased,
            purchase_link: purchaseLink?.absoluteString,
            likes_count: likesCount,
            created_at: createdAt,
            updated_at: Date()
        )
    }
}

private extension BorrowRequest {
    func toSupabaseRow() -> SupabaseBorrowRequestRow {
        SupabaseBorrowRequestRow(
            id: id,
            item_id: itemID,
            requester_id: requesterID,
            owner_id: ownerID,
            status: status.rawValue,
            requested_start_date: SupabaseDateCodec.dateString(from: requestedStartDate),
            requested_end_date: SupabaseDateCodec.dateString(from: requestedEndDate),
            message: message,
            borrower_marked_returned_at: borrowerMarkedReturnedAt,
            created_at: createdAt,
            updated_at: Date()
        )
    }
}

private extension SupabaseBorrowRequestRow {
    func toBorrowRequest() -> BorrowRequest {
        BorrowRequest(
            id: id,
            itemID: item_id,
            requesterID: requester_id,
            ownerID: owner_id,
            status: BorrowRequestStatus(rawValue: status) ?? .pending,
            requestedStartDate: SupabaseDateCodec.date(from: requested_start_date),
            requestedEndDate: SupabaseDateCodec.date(from: requested_end_date),
            message: message,
            borrowerMarkedReturnedAt: borrower_marked_returned_at,
            createdAt: created_at ?? Date()
        )
    }
}

private extension DMMessage {
    func toSupabaseRow() -> SupabaseMessageRow {
        SupabaseMessageRow(
            id: id,
            sender_id: senderID,
            recipient_id: recipientID,
            related_borrow_request_id: relatedBorrowRequestID,
            body: body,
            sent_at: sentAt,
            is_read: isRead
        )
    }
}

private extension SupabaseMessageRow {
    func toDMMessage() -> DMMessage {
        DMMessage(
            id: id,
            senderID: sender_id,
            recipientID: recipient_id,
            relatedBorrowRequestID: related_borrow_request_id,
            body: body,
            sentAt: sent_at,
            isRead: is_read
        )
    }
}
