//
//  AppState.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation
import Combine

struct NewThreadItemInput {
    var title = ""
    var brand = ""
    var size = ""
    var colorName = ""
    var imageName = ""
    var category: ClothingCategory = .tops
    var occasion: OccasionCategory = .everyday
    var condition: ItemCondition = .good
    var notes = ""
    var fitsLike = "True to size"
    var wherePurchased = ""
    var photoAspectRatio: Double = ThreadItemPhotoPolicy.fallbackAspectRatio
}

enum LikedItemsFilter: String, CaseIterable, Identifiable {
    case thisWeek
    case lastWeek
    case past30Days
    case everything

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .thisWeek: "This Week"
        case .lastWeek: "Last Week"
        case .past30Days: "Past 30 Days"
        case .everything: "Everything"
        }
    }
}

enum DiscoverFeedFilter: String, CaseIterable, Identifiable {
    case forYou
    case availableNow
    case recentlyAdded
    case friends
    case following
    case publicUsers

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forYou: "For You"
        case .availableNow: "Available Now"
        case .recentlyAdded: "New"
        case .friends: "Friends"
        case .following: "Following"
        case .publicUsers: "Public"
        }
    }
}

enum FriendConnectionState: Equatable {
    case addFriend
    case requested
    case incomingRequest
    case friends
}

enum FollowConnectionState: Equatable {
    case follow
    case requested
    case following
}

enum AppDeepLinkTarget: Equatable {
    case discoverItem(ThreadItem.ID)
    case borrowBoard
    case directMessage(userID: UserProfile.ID, itemID: ThreadItem.ID?)
    case notificationCenter
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var currentUser: UserProfile?
    @Published private(set) var users: [UserProfile] = []
    @Published private(set) var threadItems: [ThreadItem] = []
    @Published private(set) var itemComments: [ThreadItemComment] = []
    @Published private(set) var borrowRequests: [BorrowRequest] = []
    @Published private(set) var messages: [DMMessage] = []
    @Published private(set) var notifications: [ThreadNotification] = []
    @Published private(set) var notificationPreferences: ThreadNotificationPreferences?
    @Published private(set) var returnReminders: [BorrowReturnReminder] = []
    @Published private(set) var outgoingFriendRequestUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var incomingFriendRequestUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var outgoingFollowRequestUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var incomingFollowRequestUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var pendingAccountDeletionRequest: AccountDeletionRequest?
    @Published private(set) var immediateAccountDeletionNotice: ImmediateAccountDeletionNotice?
    @Published private(set) var blockedUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var pendingDeepLinkTarget: AppDeepLinkTarget?
    @Published var discoverFilter: DiscoverFeedFilter = .forYou
    @Published var threadFilter = ThreadFilter()
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: ThreadRepository
    let isDemoMode: Bool
    private let activityHeartbeatThrottle: TimeInterval = 15 * 60
    private var lastActivityHeartbeatAt: Date?
    private var hasPendingLiveRefresh = false
    
    private enum PushDispatchMode {
        case automaticFromPreferences
        case forceOn
        case forceOff
    }

    init(repository: ThreadRepository? = nil, isDemoMode: Bool = false) {
        self.repository = repository ?? LocalThreadRepository()
        self.isDemoMode = isDemoMode
    }

    func refreshLiveState() async {
        await load()
    }

    var filteredItems: [ThreadItem] {
        threadItems
            .filter { item in
                guard let currentUser else { return true }
                return item.ownerID != currentUser.id && !isBlockedUser(item.ownerID)
            }
            .filter(matchesDiscoverFilter)
            .filter { matchesThreadFilter($0, filter: threadFilter) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var friends: [UserProfile] {
        users
            .filter { user in
                guard let currentUser else { return false }
                return user.id != currentUser.id &&
                    user.relationship == .friend &&
                    !isBlockedUser(user.id)
            }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var requestedFriends: [UserProfile] {
        users
            .filter { outgoingFriendRequestUserIDs.contains($0.id) && !isBlockedUser($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var incomingFriendRequests: [UserProfile] {
        users
            .filter { incomingFriendRequestUserIDs.contains($0.id) && !isBlockedUser($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }

    var requestedFollows: [UserProfile] {
        users
            .filter { outgoingFollowRequestUserIDs.contains($0.id) && !isBlockedUser($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }

    var incomingFollowRequests: [UserProfile] {
        users
            .filter { incomingFollowRequestUserIDs.contains($0.id) && !isBlockedUser($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }

    var availableColors: [String] {
        uniqueSortedValues(\.colorName)
    }

    var availableSizes: [String] {
        uniqueSortedValues(\.size)
    }

    var availableBrands: [String] {
        uniqueSortedValues(\.brand)
    }

    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func load() async {
        guard !isLoading else {
            hasPendingLiveRefresh = true
            return
        }
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            if hasPendingLiveRefresh {
                hasPendingLiveRefresh = false
                Task { await self.load() }
            }
        }

        do {
            async let currentUser = repository.fetchCurrentUser()
            async let users = repository.fetchUsers()
            async let items = repository.fetchThreadItems()
            async let comments = repository.fetchItemComments()
            async let requests = repository.fetchBorrowRequests()
            async let messages = repository.fetchMessages()
            async let friendRequestState = repository.fetchFriendRequestState()
            async let followRequestState = repository.fetchFollowRequestState()
            async let blockedUserIDs = repository.fetchBlockedUserIDs()
            async let notifications = repository.fetchNotifications()
            async let notificationPreferences = repository.fetchNotificationPreferences()
            async let returnReminders = repository.fetchReturnReminders()

            self.currentUser = try await currentUser
            self.users = try await users
            self.threadItems = try await items
            let loadedComments = try await comments
            self.itemComments = loadedComments.sorted { $0.createdAt > $1.createdAt }
            self.borrowRequests = deduplicatedBorrowRequests(try await requests)
            self.messages = try await messages
            self.notifications = try await notifications
            let loadedNotificationPreferences = try await notificationPreferences
            self.notificationPreferences = loadedNotificationPreferences
                ?? self.currentUser.map { ThreadNotificationPreferences(userID: $0.id) }
            self.returnReminders = try await returnReminders
            let persistedFriendRequestState = try await friendRequestState
            self.outgoingFriendRequestUserIDs = persistedFriendRequestState.outgoingUserIDs
            self.incomingFriendRequestUserIDs = persistedFriendRequestState.incomingUserIDs
            let persistedFollowRequestState = try await followRequestState
            self.outgoingFollowRequestUserIDs = persistedFollowRequestState.outgoingUserIDs
            self.incomingFollowRequestUserIDs = persistedFollowRequestState.incomingUserIDs
            self.pendingAccountDeletionRequest = try await repository.fetchPendingAccountDeletionRequest()
            self.immediateAccountDeletionNotice = try await repository.fetchImmediateAccountDeletionNotice()
            self.blockedUserIDs = try await blockedUserIDs
            processDueReturnReminders()
        } catch {
            errorMessage = "Could not load ThreadShare demo data."
        }
    }

    func recordUserActivity(now: Date = Date()) {
        guard currentUser != nil else { return }

        if
            let lastActivityHeartbeatAt,
            now.timeIntervalSince(lastActivityHeartbeatAt) < activityHeartbeatThrottle
        {
            return
        }

        lastActivityHeartbeatAt = now
        Task {
            try? await repository.updateCurrentUserActivity(lastActiveAt: now)
        }
    }

    func markNotificationRead(_ notificationID: ThreadNotification.ID) {
        guard let index = notifications.firstIndex(where: { $0.id == notificationID }) else { return }
        guard notifications[index].readAt == nil else { return }

        let readAt = Date()
        notifications[index].readAt = readAt
        Task {
            try? await repository.markNotificationRead(notificationID, readAt: readAt)
        }
    }

    func markAllNotificationsRead() {
        let readAt = Date()
        for index in notifications.indices {
            notifications[index].readAt = notifications[index].readAt ?? readAt
        }
        Task {
            try? await repository.markAllNotificationsRead(readAt: readAt)
        }
    }

    func clearPendingDeepLinkTarget() {
        pendingDeepLinkTarget = nil
    }

    func handlePushNotificationTap(notificationID: ThreadNotification.ID) {
        if let notification = notifications.first(where: { $0.id == notificationID }) {
            routeToDeepLink(for: notification)
            return
        }

        Task {
            await load()
            if let notification = notifications.first(where: { $0.id == notificationID }) {
                routeToDeepLink(for: notification)
            } else {
                pendingDeepLinkTarget = .notificationCenter
            }
        }
    }

    func openNotification(_ notification: ThreadNotification) {
        routeToDeepLink(for: notification)
    }

    func saveNotificationPreferences(_ preferences: ThreadNotificationPreferences) {
        notificationPreferences = preferences
        Task {
            try? await repository.saveNotificationPreferences(preferences)
        }
    }

    func conversationMessages(with otherUserID: UserProfile.ID) -> [DMMessage] {
        guard let currentUser else { return [] }
        return messages
            .filter { message in
                (message.senderID == currentUser.id && message.recipientID == otherUserID) ||
                (message.senderID == otherUserID && message.recipientID == currentUser.id)
            }
            .sorted { $0.sentAt < $1.sentAt }
    }

    func markConversationRead(with otherUserID: UserProfile.ID) {
        guard let currentUser else { return }

        var hasChanges = false
        for index in messages.indices {
            if messages[index].senderID == otherUserID, messages[index].recipientID == currentUser.id, !messages[index].isRead {
                messages[index].isRead = true
                hasChanges = true
            }
        }

        guard hasChanges else { return }
        Task {
            try? await repository.markMessagesRead(from: otherUserID, to: currentUser.id)
        }
    }

    @discardableResult
    func sendDirectMessage(
        to recipientID: UserProfile.ID,
        body: String,
        relatedBorrowRequestID: BorrowRequest.ID? = nil,
        itemID: ThreadItem.ID? = nil
    ) -> DMMessage? {
        guard let currentUser else { return nil }
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedBody.isEmpty == false else { return nil }
        guard recipientID != currentUser.id else { return nil }

        let message = DMMessage(
            senderID: currentUser.id,
            recipientID: recipientID,
            relatedBorrowRequestID: relatedBorrowRequestID,
            body: trimmedBody
        )
        messages.append(message)
        messages.sort { $0.sentAt < $1.sentAt }

        Task {
            do {
                try await repository.saveMessage(message)

                createNotification(
                    recipientID: recipientID,
                    actorID: currentUser.id,
                    kind: .directMessage,
                    title: "New message",
                    body: "\(currentUser.displayName): \(trimmedBody)",
                    itemID: itemID,
                    messageID: message.id
                )
            } catch {
                messages.removeAll { $0.id == message.id }
                errorMessage = "Message could not be sent. Please try again."
                await load()
            }
        }

        return message
    }

    func returnReminder(for requestID: BorrowRequest.ID) -> BorrowReturnReminder? {
        returnReminders.first { $0.borrowRequestID == requestID && $0.isEnabled }
    }

    func setReturnReminder(for request: BorrowRequest, cadence: ReturnReminderCadence?) {
        guard let currentUser, request.requesterID == currentUser.id else { return }
        let now = Date()
        let nextReminderAt = Calendar.current.date(byAdding: .day, value: -1, to: request.requestedEndDate) ?? request.requestedEndDate
        let scheduledDate = max(now, nextReminderAt)

        let reminder: BorrowReturnReminder
        if let existingIndex = returnReminders.firstIndex(where: { $0.borrowRequestID == request.id && $0.userID == currentUser.id }) {
            if let cadence {
                returnReminders[existingIndex].cadence = cadence
                returnReminders[existingIndex].nextReminderAt = scheduledDate
                returnReminders[existingIndex].isEnabled = true
            } else {
                returnReminders[existingIndex].isEnabled = false
            }
            returnReminders[existingIndex].updatedAt = now
            reminder = returnReminders[existingIndex]
        } else if let cadence {
            reminder = BorrowReturnReminder(
                userID: currentUser.id,
                borrowRequestID: request.id,
                cadence: cadence,
                nextReminderAt: scheduledDate
            )
            returnReminders.append(reminder)
        } else {
            return
        }

        Task {
            try? await repository.saveReturnReminder(reminder)
        }
    }

    func processDueReturnReminders(now: Date = Date()) {
        guard let currentUser else { return }

        for index in returnReminders.indices {
            var reminder = returnReminders[index]
            guard reminder.userID == currentUser.id, reminder.isEnabled, reminder.nextReminderAt <= now else { continue }
            guard let request = borrowRequests.first(where: { $0.id == reminder.borrowRequestID }) else { continue }

            guard request.status == .approved else {
                reminder.isEnabled = false
                reminder.updatedAt = now
                returnReminders[index] = reminder
                Task { try? await repository.saveReturnReminder(reminder) }
                continue
            }

            let itemTitle = threadItems.first { $0.id == request.itemID }?.title ?? "borrowed item"
            createNotification(
                recipientID: currentUser.id,
                actorID: request.ownerID,
                kind: .returnReminder,
                title: "Return reminder",
                body: "Remember to return \(itemTitle) by \(request.requestedEndDate.formatted(date: .abbreviated, time: .omitted)).",
                itemID: request.itemID,
                borrowRequestID: request.id
            )

            reminder.lastSentAt = now
            reminder.updatedAt = now
            switch reminder.cadence {
            case .oneTime:
                reminder.isEnabled = false
            case .daily:
                reminder.nextReminderAt = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86_400)
            }
            returnReminders[index] = reminder
            Task { try? await repository.saveReturnReminder(reminder) }
        }
    }

    private func createNotification(
        recipientID: UserProfile.ID,
        actorID: UserProfile.ID?,
        kind: ThreadNotificationKind,
        title: String,
        body: String,
        itemID: ThreadItem.ID? = nil,
        borrowRequestID: BorrowRequest.ID? = nil,
        messageID: DMMessage.ID? = nil,
        pushDispatchMode: PushDispatchMode = .automaticFromPreferences
    ) {
        let notification = ThreadNotification(
            recipientID: recipientID,
            actorID: actorID,
            kind: kind,
            title: title,
            body: body,
            itemID: itemID,
            borrowRequestID: borrowRequestID,
            messageID: messageID
        )

        if recipientID == currentUser?.id {
            notifications.insert(notification, at: 0)
        }

        Task {
            do {
                try await repository.saveNotification(notification)
                let shouldDispatchPush: Bool
                switch pushDispatchMode {
                case .forceOn:
                    shouldDispatchPush = true
                case .forceOff:
                    shouldDispatchPush = false
                case .automaticFromPreferences:
                    shouldDispatchPush = true
                }

                if shouldDispatchPush {
                    try await repository.dispatchPushNotification(notification.id)
                }
            } catch {
                // Keep notification UX non-blocking, but leave a debug breadcrumb.
                #if DEBUG
                print("ThreadShare notification dispatch failed: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    private func routeToDeepLink(for notification: ThreadNotification) {
        markNotificationRead(notification.id)

        switch notification.kind {
        case .borrowRequest, .borrowRequestStatus, .returnReminder, .itemReturned, .itemNeedsReturn:
            pendingDeepLinkTarget = .borrowBoard
        case .directMessage:
            if let senderID = notification.actorID {
                pendingDeepLinkTarget = .directMessage(userID: senderID, itemID: notification.itemID)
            } else {
                pendingDeepLinkTarget = .notificationCenter
            }
        case .itemLike, .itemComment, .friendRecentlyAdded:
            if
                let itemID = notification.itemID,
                threadItems.contains(where: { $0.id == itemID })
            {
                pendingDeepLinkTarget = .discoverItem(itemID)
            } else {
                pendingDeepLinkTarget = .notificationCenter
            }
        case .friendTaggedItem:
            if
                let itemID = notification.itemID,
                threadItems.contains(where: { $0.id == itemID })
            {
                pendingDeepLinkTarget = .discoverItem(itemID)
            } else {
                pendingDeepLinkTarget = .notificationCenter
            }
        }
    }

    @discardableResult
    func tagFriend(_ friendID: UserProfile.ID, for item: ThreadItem) -> Bool {
        guard let currentUser else { return false }
        guard friendID != currentUser.id else { return false }
        guard let friend = user(withID: friendID), friend.relationship == .friend else { return false }

        createNotification(
            recipientID: friendID,
            actorID: currentUser.id,
            kind: .friendTaggedItem,
            title: "\(currentUser.displayName) tagged you",
            body: "\(currentUser.displayName) tagged you in \(item.title).",
            itemID: item.id
        )
        return true
    }

    private func notifyFriendsAboutNewItem(_ item: ThreadItem) async {
        guard let currentUser else { return }

        let recipients = users.filter { user in
            user.id != currentUser.id &&
            user.relationship == .friend &&
            !isBlockedUser(user.id)
        }

        for recipient in recipients {
            let preferences = (try? await repository.fetchNotificationPreferences(for: recipient.id))
                ?? ThreadNotificationPreferences(userID: recipient.id)

            guard preferences.friendNewItemAlertsEnabled else { continue }

            createNotification(
                recipientID: recipient.id,
                actorID: currentUser.id,
                kind: .friendRecentlyAdded,
                title: "\(currentUser.displayName) added something new",
                body: "\(currentUser.displayName) added \(item.title) to their closet.",
                itemID: item.id
            )
        }
    }

    func resetFilters() {
        discoverFilter = .forYou
        threadFilter = ThreadFilter()
    }

    func applyFilter(_ filter: ThreadFilter) {
        threadFilter = filter
    }

    func filteredItems(matching filter: ThreadFilter) -> [ThreadItem] {
        threadItems
            .filter { !isBlockedUser($0.ownerID) }
            .filter(matchesDiscoverFilter)
            .filter { matchesThreadFilter($0, filter: filter) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func owner(for item: ThreadItem) -> UserProfile? {
        guard !isBlockedUser(item.ownerID) else { return nil }
        return user(withID: item.ownerID)
    }

    func user(withID userID: UserProfile.ID) -> UserProfile? {
        if currentUser?.id == userID {
            return currentUser
        }

        return users.first { $0.id == userID }
    }

    var canManageFollowGraph: Bool {
        !isDemoMode
    }

    func isCurrentUser(id: UserProfile.ID) -> Bool {
        currentUser?.id == id
    }

    func items(for owner: UserProfile) -> [ThreadItem] {
        guard !isBlockedUser(owner.id) else { return [] }
        return threadItems
            .filter { $0.ownerID == owner.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func comments(for itemID: ThreadItem.ID) -> [ThreadItemComment] {
        itemComments
            .filter { $0.itemID == itemID && !isBlockedUser($0.authorID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func author(for comment: ThreadItemComment) -> UserProfile? {
        guard !isBlockedUser(comment.authorID) else { return nil }
        if currentUser?.id == comment.authorID {
            return currentUser
        }
        return users.first { $0.id == comment.authorID }
    }

    func toggleLike(for itemID: ThreadItem.ID) {
        guard let index = threadItems.firstIndex(where: { $0.id == itemID }) else { return }

        let wasLiked = threadItems[index].isLikedByCurrentUser
        let currentCount = threadItems[index].likesCount
        threadItems[index].isLikedByCurrentUser.toggle()
        let delta = threadItems[index].isLikedByCurrentUser ? 1 : -1
        threadItems[index].likesCount = max(0, currentCount + delta)
        if wasLiked && threadItems[index].likesCount == 0 {
            threadItems[index].isLikedByCurrentUser = false
        }
        threadItems[index].likedAt = threadItems[index].isLikedByCurrentUser ? Date() : nil

        let updatedItem = threadItems[index]
        Task {
            do {
                try await repository.setItemLiked(
                    updatedItem.id,
                    liked: updatedItem.isLikedByCurrentUser,
                    likedAt: updatedItem.likedAt
                )

                if
                    updatedItem.isLikedByCurrentUser,
                    let currentUser,
                    updatedItem.ownerID != currentUser.id
                {
                    createNotification(
                        recipientID: updatedItem.ownerID,
                        actorID: currentUser.id,
                        kind: .itemLike,
                        title: "New like",
                        body: "\(currentUser.displayName) liked \(updatedItem.title).",
                        itemID: updatedItem.id
                    )
                }
            } catch {
                errorMessage = "Like could not be saved. Please try again."
                await load()
            }
        }
    }

    func toggleFollow(for userID: UserProfile.ID) {
        guard let currentUser, userID != currentUser.id else { return }
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }
        let targetUser = users[index]

        switch followConnectionState(for: userID) {
        case .following:
            setFollowedState(for: userID, followed: false)
        case .requested:
            cancelFollowRequest(to: userID)
        case .follow:
            if targetUser.requiresFollowerApproval {
                requestFollow(to: userID)
            } else {
                setFollowedState(for: userID, followed: true)
            }
        }
    }

    @discardableResult
    func unfollow(_ userID: UserProfile.ID) -> Bool {
        guard let currentUser, userID != currentUser.id else { return false }
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return false }
        guard users[index].isFollowedByCurrentUser else { return false }
        setFollowedState(for: userID, followed: false)
        return true
    }

    @discardableResult
    func removeFollower(_ followerID: UserProfile.ID) -> Bool {
        guard var currentUser = currentUser, followerID != currentUser.id else { return false }
        guard let index = users.firstIndex(where: { $0.id == followerID }) else { return false }

        currentUser.followerCount = max(0, currentUser.followerCount - 1)
        users[index].followingCount = max(0, users[index].followingCount - 1)
        self.currentUser = currentUser
        syncCurrentUserIntoUsers()

        let updatedFollower = users[index]
        let updatedCurrentUser = currentUser
        Task {
            try? await repository.removeFollower(followerID, from: updatedCurrentUser.id)
            try? await repository.saveUser(updatedFollower)
            try? await repository.saveUser(updatedCurrentUser)
        }
        return true
    }

    private func setFollowedState(for userID: UserProfile.ID, followed: Bool) {
        guard var currentUser = currentUser, let index = users.firstIndex(where: { $0.id == userID }) else { return }

        let wasFollowing = users[index].isFollowedByCurrentUser
        guard wasFollowing != followed else { return }

        users[index].isFollowedByCurrentUser = followed
        if followed {
            outgoingFollowRequestUserIDs.remove(userID)
        }
        users[index].followerCount = max(0, users[index].followerCount + (followed ? 1 : -1))

        if followed && users[index].relationship == .publicUser {
            users[index].relationship = .follower
        } else if !followed && users[index].relationship == .follower {
            users[index].relationship = .publicUser
        }

        currentUser.followingCount = max(0, currentUser.followingCount + (followed ? 1 : -1))
        self.currentUser = currentUser
        syncCurrentUserIntoUsers()

        let updatedUser = users[index]
        let updatedCurrentUser = currentUser
        Task {
            try? await repository.saveUser(updatedCurrentUser)
            try? await repository.saveUser(updatedUser)
            try? await repository.setUserFollowed(updatedUser.id, followed: followed)
        }
    }

    private func syncCurrentUserIntoUsers() {
        guard let currentUser, let index = users.firstIndex(where: { $0.id == currentUser.id }) else { return }
        users[index] = currentUser
    }

    func requestFriend(for userID: UserProfile.ID) {
        sendFriendRequest(to: userID)
    }

    func requestFollow(to userID: UserProfile.ID) {
        guard let currentUser else { return }
        guard userID != currentUser.id else { return }
        guard !isBlockedUser(userID) else { return }
        guard followConnectionState(for: userID) == .follow else { return }
        outgoingFollowRequestUserIDs.insert(userID)
        Task {
            try? await repository.requestFollow(to: userID)
            await refreshSocialState()
        }
    }

    func cancelFollowRequest(to userID: UserProfile.ID) {
        outgoingFollowRequestUserIDs.remove(userID)
        Task {
            try? await repository.cancelFollowRequest(to: userID)
            await refreshSocialState()
        }
    }

    func approveFollowRequest(from userID: UserProfile.ID) {
        guard var currentUser = currentUser else { return }
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }

        incomingFollowRequestUserIDs.remove(userID)
        currentUser.followerCount += 1
        users[index].followingCount += 1
        self.currentUser = currentUser
        syncCurrentUserIntoUsers()

        let updatedUser = users[index]
        let updatedCurrentUser = currentUser
        Task {
            try? await repository.saveUser(updatedUser)
            try? await repository.saveUser(updatedCurrentUser)
            try? await repository.approveFollowRequest(from: userID)
            await refreshSocialState()
        }
    }

    func denyFollowRequest(from userID: UserProfile.ID) {
        incomingFollowRequestUserIDs.remove(userID)
        Task {
            try? await repository.denyFollowRequest(from: userID)
            await refreshSocialState()
        }
    }

    func sendFriendRequest(to userID: UserProfile.ID) {
        guard let currentUser else { return }
        guard userID != currentUser.id else { return }
        guard !isBlockedUser(userID) else { return }
        guard friendConnectionState(for: userID) == .addFriend else { return }
        outgoingFriendRequestUserIDs.insert(userID)
        Task {
            try? await repository.sendFriendRequest(to: userID)
            await refreshSocialState()
        }
    }

    func cancelFriendRequest(to userID: UserProfile.ID) {
        outgoingFriendRequestUserIDs.remove(userID)
        Task {
            try? await repository.cancelFriendRequest(to: userID)
            await refreshSocialState()
        }
    }

    func approveFriendRequest(from userID: UserProfile.ID) {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }
        incomingFriendRequestUserIDs.remove(userID)

        users[index].relationship = .friend

        let updatedUser = users[index]
        Task {
            try? await repository.saveUser(updatedUser)
            try? await repository.approveFriendRequest(from: userID)
            await refreshSocialState()
        }
    }
    
    func denyFriendRequest(from userID: UserProfile.ID) {
        incomingFriendRequestUserIDs.remove(userID)
        Task {
            try? await repository.denyFriendRequest(from: userID)
            await refreshSocialState()
        }
    }

    func removeFriend(_ userID: UserProfile.ID) -> Bool {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return false }
        guard users[index].relationship == .friend else { return false }

        users[index].relationship = .publicUser
        let updatedUser = users[index]

        Task {
            try? await repository.saveUser(updatedUser)
            await refreshSocialState()
        }

        return true
    }

    func hasSentFriendRequest(to userID: UserProfile.ID) -> Bool {
        outgoingFriendRequestUserIDs.contains(userID)
    }

    func hasIncomingFriendRequest(from userID: UserProfile.ID) -> Bool {
        incomingFriendRequestUserIDs.contains(userID)
    }

    func followConnectionState(for userID: UserProfile.ID) -> FollowConnectionState {
        guard let user = users.first(where: { $0.id == userID }) else {
            return .follow
        }

        if user.isFollowedByCurrentUser {
            return .following
        }
        if outgoingFollowRequestUserIDs.contains(userID) {
            return .requested
        }
        return .follow
    }

    func followingUsers(for userID: UserProfile.ID) -> [UserProfile] {
        guard let currentUser, userID == currentUser.id else { return [] }
        return users
            .filter { $0.id != userID && $0.isFollowedByCurrentUser && !isBlockedUser($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }

    func followerUsers(for userID: UserProfile.ID) async -> [UserProfile] {
        guard let currentUser, userID == currentUser.id else { return [] }

        do {
            let followerIDs = try await repository.fetchFollowerUserIDs(for: userID)
            return followerIDs
                .compactMap { user(withID: $0) }
                .filter { !isBlockedUser($0.id) && $0.id != currentUser.id }
                .sorted { $0.displayName < $1.displayName }
        } catch {
            return []
        }
    }

    func friendConnectionState(for userID: UserProfile.ID) -> FriendConnectionState {
        if friends.contains(where: { $0.id == userID }) {
            return .friends
        }
        if incomingFriendRequestUserIDs.contains(userID) {
            return .incomingRequest
        }
        if outgoingFriendRequestUserIDs.contains(userID) {
            return .requested
        }
        return .addFriend
    }

    func visibleFriendRequests(on profile: UserProfile) -> [UserProfile] {
        guard !isBlockedUser(profile.id) else { return [] }
        if isCurrentUser(id: profile.id) {
            return incomingFriendRequests
        }

        guard
            outgoingFriendRequestUserIDs.contains(profile.id),
            let currentUser
        else {
            return []
        }

        return [currentUser]
            .filter { !isBlockedUser($0.id) }
    }

    func potentialFriends(matching query: String) -> [UserProfile] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return [] }

        return users
            .filter { user in
                guard let currentUser else { return false }
                guard user.id != currentUser.id else { return false }
                guard !isBlockedUser(user.id) else { return false }
                return user.displayName.lowercased().contains(normalized) ||
                    user.username.lowercased().contains(normalized)
            }
            .sorted { $0.displayName < $1.displayName }
    }

    func updateCurrentUser(_ updatedUser: UserProfile) {
        currentUser = updatedUser

        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
        } else {
            users.insert(updatedUser, at: 0)
        }

        Task {
            try? await repository.saveUser(updatedUser)
        }
    }

    func likedItems(filter: LikedItemsFilter) -> [ThreadItem] {
        let calendar = Calendar.current
        let now = Date()

        return threadItems
            .filter { $0.isLikedByCurrentUser && !isBlockedUser($0.ownerID) }
            .filter { item in
                guard let likedAt = item.likedAt else { return filter == .everything }

                switch filter {
                case .everything:
                    return true
                case .past30Days:
                    guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) else { return true }
                    return likedAt >= thirtyDaysAgo
                case .thisWeek:
                    guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return true }
                    return weekInterval.contains(likedAt)
                case .lastWeek:
                    guard
                        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now),
                        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)
                    else {
                        return true
                    }
                    let lastWeekRange = DateInterval(start: lastWeekStart, end: currentWeek.start)
                    return lastWeekRange.contains(likedAt)
                }
            }
            .sorted { ($0.likedAt ?? .distantPast) > ($1.likedAt ?? .distantPast) }
    }

    @discardableResult
    func requestToBorrow(
        itemID: ThreadItem.ID,
        startDate: Date,
        endDate: Date,
        message: String
    ) -> BorrowRequest? {
        guard
            let currentUser,
            let itemIndex = threadItems.firstIndex(where: { $0.id == itemID }),
            threadItems[itemIndex].availabilityStatus == .available
        else {
            return nil
        }

        if let existing = borrowRequests.first(where: {
            $0.itemID == itemID &&
            $0.requesterID == currentUser.id &&
            ($0.status == .pending || $0.status == .approved || $0.status == .returnPendingOwnerConfirmation)
        }) {
            return existing
        }

        threadItems[itemIndex].availabilityStatus = .requested

        let request = BorrowRequest(
            itemID: itemID,
            requesterID: currentUser.id,
            ownerID: threadItems[itemIndex].ownerID,
            status: .pending,
            requestedStartDate: startDate,
            requestedEndDate: endDate,
            message: message
        )

        borrowRequests.insert(request, at: 0)
        borrowRequests = deduplicatedBorrowRequests(borrowRequests)
        let updatedItem = threadItems[itemIndex]

        Task {
            do {
                try await repository.saveBorrowRequest(request)

                createNotification(
                    recipientID: request.ownerID,
                    actorID: currentUser.id,
                    kind: .borrowRequest,
                    title: "Borrow request",
                    body: "\(currentUser.displayName) requested \(updatedItem.title).",
                    itemID: updatedItem.id,
                    borrowRequestID: request.id
                )
            } catch {
                // If a concurrent request already exists in backend, resync local state.
                await load()
            }
        }

        return request
    }

    func updateBorrowRequest(_ requestID: BorrowRequest.ID, status: BorrowRequestStatus) {
        guard let currentUser else { return }
        guard let requestIndex = borrowRequests.firstIndex(where: { $0.id == requestID }) else { return }

        let request = borrowRequests[requestIndex]
        let isOwner = request.ownerID == currentUser.id
        let isBorrower = request.requesterID == currentUser.id

        switch status {
        case .approved, .declined:
            guard
                (isOwner && request.status == .pending) ||
                (isBorrower && request.status == .returnPendingOwnerConfirmation && status == .approved)
            else { return }
        case .returned:
            guard isOwner, (request.status == .approved || request.status == .returnPendingOwnerConfirmation) else { return }
        case .returnPendingOwnerConfirmation:
            guard isBorrower, request.status == .approved else { return }
        case .pending:
            return
        }

        borrowRequests[requestIndex].status = status
        if status == .returnPendingOwnerConfirmation {
            borrowRequests[requestIndex].borrowerMarkedReturnedAt = Date()
        } else if status == .returned {
            if borrowRequests[requestIndex].borrowerMarkedReturnedAt == nil {
                borrowRequests[requestIndex].borrowerMarkedReturnedAt = Date()
            }
        } else if status == .approved && isBorrower && request.status == .returnPendingOwnerConfirmation {
            borrowRequests[requestIndex].borrowerMarkedReturnedAt = nil
        } else {
            borrowRequests[requestIndex].borrowerMarkedReturnedAt = nil
        }

        if let itemIndex = threadItems.firstIndex(where: { $0.id == borrowRequests[requestIndex].itemID }) {
            switch status {
            case .pending:
                threadItems[itemIndex].availabilityStatus = .requested
            case .approved, .returnPendingOwnerConfirmation:
                threadItems[itemIndex].availabilityStatus = .borrowed
            case .declined, .returned:
                threadItems[itemIndex].availabilityStatus = .available
            }
        }

        let updatedRequest = borrowRequests[requestIndex]
        if status != .approved {
            disableReturnReminder(for: updatedRequest.id)
        }

        Task {
            do {
                try await repository.saveBorrowRequest(updatedRequest)
                if
                    isOwner,
                    let updatedItem = threadItems.first(where: { $0.id == updatedRequest.itemID })
                {
                    try await repository.saveThreadItem(updatedItem)
                }

                switch status {
                case .returnPendingOwnerConfirmation:
                    let itemTitle = threadItems.first(where: { $0.id == updatedRequest.itemID })?.title ?? "this item"
                    createNotification(
                        recipientID: updatedRequest.ownerID,
                        actorID: currentUser.id,
                        kind: .itemNeedsReturn,
                        title: "Borrower marked returned",
                        body: "\(currentUser.displayName) marked \(itemTitle) as returned. Confirm when received.",
                        itemID: updatedRequest.itemID,
                        borrowRequestID: updatedRequest.id
                    )
                case .returned:
                    createNotification(
                        recipientID: updatedRequest.requesterID,
                        actorID: currentUser.id,
                        kind: .itemReturned,
                        title: "Return confirmed",
                        body: "The owner confirmed your item return.",
                        itemID: updatedRequest.itemID,
                        borrowRequestID: updatedRequest.id
                    )
                case .approved, .declined:
                    createNotification(
                        recipientID: updatedRequest.requesterID,
                        actorID: currentUser.id,
                        kind: .borrowRequestStatus,
                        title: "Borrow request updated",
                        body: "Your request was marked \(status.displayName.lowercased()).",
                        itemID: updatedRequest.itemID,
                        borrowRequestID: updatedRequest.id
                    )
                case .pending:
                    break
                }
            } catch {
                errorMessage = "Borrow request could not be updated. Please try again."
                await load()
            }
        }
    }

    func borrowerMarkedRequestReturned(_ requestID: BorrowRequest.ID) {
        updateBorrowRequest(requestID, status: .returnPendingOwnerConfirmation)
    }

    func borrowerToggledReturnedState(_ requestID: BorrowRequest.ID) {
        guard let request = borrowRequests.first(where: { $0.id == requestID }) else { return }
        switch request.status {
        case .approved:
            updateBorrowRequest(requestID, status: .returnPendingOwnerConfirmation)
        case .returnPendingOwnerConfirmation:
            updateBorrowRequest(requestID, status: .approved)
        default:
            return
        }
    }

    func ownerConfirmedRequestReturned(_ requestID: BorrowRequest.ID) {
        updateBorrowRequest(requestID, status: .returned)
    }

    private func disableReturnReminder(for requestID: BorrowRequest.ID) {
        guard let index = returnReminders.firstIndex(where: { $0.borrowRequestID == requestID && $0.isEnabled }) else { return }
        returnReminders[index].isEnabled = false
        returnReminders[index].updatedAt = Date()
        let reminder = returnReminders[index]
        Task {
            try? await repository.saveReturnReminder(reminder)
        }
    }

    @discardableResult
    func updateOwnedItemAvailability(
        itemID: ThreadItem.ID,
        status: ItemAvailabilityStatus
    ) -> Bool {
        guard let currentUser else { return false }
        guard let itemIndex = threadItems.firstIndex(where: { $0.id == itemID }) else { return false }
        guard threadItems[itemIndex].ownerID == currentUser.id else { return false }

        let currentStatus = threadItems[itemIndex].availabilityStatus
        guard currentStatus != status else { return false }
        guard [ItemAvailabilityStatus.available, .notAvailable].contains(currentStatus) else { return false }
        guard [ItemAvailabilityStatus.available, .notAvailable].contains(status) else { return false }

        threadItems[itemIndex].availabilityStatus = status
        let updatedItem = threadItems[itemIndex]

        Task {
            try? await repository.saveThreadItem(updatedItem)
        }

        return true
    }

    @discardableResult
    func addThreadItem(_ input: NewThreadItemInput) -> ThreadItem? {
        guard let currentUser else { return nil }

        let newItem = makeThreadItem(from: input, ownerID: currentUser.id)

        threadItems.insert(newItem, at: 0)
        Task {
            try? await repository.saveThreadItem(newItem)
            await notifyFriendsAboutNewItem(newItem)
        }
        return newItem
    }

    @discardableResult
    func addThreadItem(_ input: NewThreadItemInput, imageData: Data?) async throws -> ThreadItem? {
        guard let currentUser else { return nil }

        var newItem = makeThreadItem(from: input, ownerID: currentUser.id)
        var uploadedImagePath: String?

        if let imageData {
            let imagePath = try await repository.saveThreadItemImageData(imageData, for: newItem)
            newItem.imageName = imagePath
            uploadedImagePath = imagePath
        }

        do {
            try await repository.saveThreadItem(newItem)
            threadItems.insert(newItem, at: 0)
            Task { await notifyFriendsAboutNewItem(newItem) }
            return newItem
        } catch {
            if let uploadedImagePath {
                try? await repository.deleteThreadItemImage(at: uploadedImagePath)
            }
            throw error
        }
    }

    private func makeThreadItem(from input: NewThreadItemInput, ownerID: UserProfile.ID) -> ThreadItem {
        ThreadItem(
            ownerID: ownerID,
            title: input.title.trimmingCharacters(in: .whitespacesAndNewlines),
            brand: input.brand.trimmingCharacters(in: .whitespacesAndNewlines),
            size: input.size.trimmingCharacters(in: .whitespacesAndNewlines),
            colorName: input.colorName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: input.category,
            occasions: [input.occasion],
            condition: input.condition,
            availabilityStatus: .available,
            imageName: input.imageName,
            photoAspectRatio: input.photoAspectRatio,
            notes: input.notes.trimmingCharacters(in: .whitespacesAndNewlines),
            fitsLike: input.fitsLike.trimmingCharacters(in: .whitespacesAndNewlines),
            wherePurchased: input.wherePurchased.trimmingCharacters(in: .whitespacesAndNewlines),
            likesCount: 0
        )
    }

    private func deduplicatedBorrowRequests(_ requests: [BorrowRequest]) -> [BorrowRequest] {
        let sorted = requests.sorted { $0.createdAt > $1.createdAt }
        var seenRequestIDs = Set<BorrowRequest.ID>()
        var seenActivePairs = Set<String>()
        var result: [BorrowRequest] = []

        for request in sorted {
            guard seenRequestIDs.insert(request.id).inserted else { continue }

            let activePairKey = "\(request.itemID.uuidString)|\(request.requesterID.uuidString)"
            if (request.status == .pending || request.status == .approved || request.status == .returnPendingOwnerConfirmation) && !seenActivePairs.insert(activePairKey).inserted {
                continue
            }

            result.append(request)
        }

        return result
    }

    private func refreshSocialState() async {
        do {
            async let refreshedUsers = repository.fetchUsers()
            async let refreshedFriendState = repository.fetchFriendRequestState()
            async let refreshedFollowState = repository.fetchFollowRequestState()
            users = try await refreshedUsers
            let state = try await refreshedFriendState
            outgoingFriendRequestUserIDs = state.outgoingUserIDs
            incomingFriendRequestUserIDs = state.incomingUserIDs
            let followState = try await refreshedFollowState
            outgoingFollowRequestUserIDs = followState.outgoingUserIDs
            incomingFollowRequestUserIDs = followState.incomingUserIDs
        } catch {
            // Keep UI responsive even if background social refresh fails.
        }
    }

    @discardableResult
    func addComment(to itemID: ThreadItem.ID, body: String) -> ThreadItemComment? {
        guard let currentUser else { return nil }
        guard threadItems.contains(where: { $0.id == itemID }) else { return nil }

        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedBody.isEmpty == false else { return nil }

        let comment = ThreadItemComment(
            itemID: itemID,
            authorID: currentUser.id,
            body: trimmedBody
        )
        itemComments.append(comment)
        itemComments.sort { $0.createdAt > $1.createdAt }

        Task {
            do {
                try await repository.saveItemComment(comment)

                if let item = threadItems.first(where: { $0.id == itemID }), item.ownerID != currentUser.id {
                    createNotification(
                        recipientID: item.ownerID,
                        actorID: currentUser.id,
                        kind: .itemComment,
                        title: "New comment",
                        body: "\(currentUser.displayName) commented on \(item.title).",
                        itemID: item.id
                    )
                }
            } catch {
                itemComments.removeAll { $0.id == comment.id }
                errorMessage = "Comment could not be posted. Please try again."
                await load()
            }
        }

        return comment
    }

    func canDeleteComment(_ comment: ThreadItemComment) -> Bool {
        guard let currentUser else { return false }
        guard let item = threadItems.first(where: { $0.id == comment.itemID }) else { return false }
        return comment.authorID == currentUser.id || item.ownerID == currentUser.id
    }

    @discardableResult
    func deleteComment(_ commentID: ThreadItemComment.ID) -> Bool {
        guard let comment = itemComments.first(where: { $0.id == commentID }) else { return false }
        guard canDeleteComment(comment) else { return false }

        itemComments.removeAll { $0.id == commentID }
        Task {
            try? await repository.deleteItemComment(commentID)
        }
        return true
    }

    @discardableResult
    func deleteThreadItem(_ itemID: ThreadItem.ID) -> Bool {
        guard
            let item = threadItems.first(where: { $0.id == itemID }),
            isCurrentUser(id: item.ownerID)
        else {
            return false
        }

        threadItems.removeAll { $0.id == itemID }
        itemComments.removeAll { $0.itemID == itemID }
        borrowRequests.removeAll { $0.itemID == itemID }

        Task {
            try? await repository.deleteThreadItem(itemID)
        }

        return true
    }

    func submitItemReport(
        itemID: ThreadItem.ID,
        reason: ItemReportReason,
        details: String
    ) {
        guard let currentUser else { return }
        guard let item = threadItems.first(where: { $0.id == itemID }) else { return }

        let report = ItemReport(
            reporterID: currentUser.id,
            itemID: itemID,
            ownerID: item.ownerID,
            reason: reason,
            details: details.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        Task {
            try? await repository.saveItemReport(report)
        }
    }

    func loadPendingAccountDeletionRequest() async {
        pendingAccountDeletionRequest = try? await repository.fetchPendingAccountDeletionRequest()
        immediateAccountDeletionNotice = try? await repository.fetchImmediateAccountDeletionNotice()
    }

    func canBlockUser(_ userID: UserProfile.ID) -> Bool {
        guard let currentUser else { return false }
        return userID != currentUser.id && !blockedUserIDs.contains(userID)
    }

    func isBlockedUser(_ userID: UserProfile.ID) -> Bool {
        blockedUserIDs.contains(userID)
    }

    var blockedUsers: [UserProfile] {
        users
            .filter { blockedUserIDs.contains($0.id) && !isCurrentUser(id: $0.id) }
            .sorted { $0.displayName < $1.displayName }
    }

    @discardableResult
    func blockUser(_ userID: UserProfile.ID) -> Bool {
        guard canBlockUser(userID) else { return false }

        blockedUserIDs.insert(userID)
        outgoingFriendRequestUserIDs.remove(userID)
        incomingFriendRequestUserIDs.remove(userID)
        borrowRequests.removeAll { $0.requesterID == userID || $0.ownerID == userID }
        messages.removeAll { $0.senderID == userID || $0.recipientID == userID }

        Task {
            try? await repository.blockUser(userID)
        }

        return true
    }

    @discardableResult
    func unblockUser(_ userID: UserProfile.ID) -> Bool {
        guard blockedUserIDs.contains(userID) else { return false }
        blockedUserIDs.remove(userID)

        Task {
            try? await repository.unblockUser(userID)
        }

        return true
    }

    @discardableResult
    func requestAccountDeletion() async -> AccountDeletionRequest? {
        guard let currentUser else { return nil }
        do {
            let request = try await repository.requestAccountDeletion(for: currentUser.id)
            pendingAccountDeletionRequest = request
            return request
        } catch {
            return nil
        }
    }

    func cancelAccountDeletion() async -> Bool {
        guard let currentUser else { return false }
        do {
            try await repository.cancelAccountDeletion(for: currentUser.id)
            pendingAccountDeletionRequest = nil
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    func requestImmediateAccountDeletion(
        confirmationStatement: String
    ) async -> ImmediateAccountDeletionNotice? {
        guard let currentUser else { return nil }
        do {
            let notice = try await repository.requestImmediateAccountDeletion(
                for: currentUser.id,
                confirmationStatement: confirmationStatement
            )
            immediateAccountDeletionNotice = notice
            return notice
        } catch {
            return nil
        }
    }

    private func matchesDiscoverFilter(_ item: ThreadItem) -> Bool {
        switch discoverFilter {
        case .forYou:
            return true
        case .availableNow:
            return item.availabilityStatus == .available
        case .recentlyAdded:
            guard item.isRecentlyAdded, let owner = owner(for: item) else { return false }
            return owner.relationship == .friend || owner.isFollowedByCurrentUser
        case .friends:
            return owner(for: item)?.relationship == .friend
        case .following:
            return owner(for: item)?.isFollowedByCurrentUser == true
        case .publicUsers:
            return owner(for: item)?.relationship == .publicUser
        }
    }

    private func matchesThreadFilter(_ item: ThreadItem, filter: ThreadFilter) -> Bool {
        if filter.availableNowOnly && item.availabilityStatus != .available {
            return false
        }

        if let colorName = filter.colorName, item.colorName != colorName {
            return false
        }

        if let size = filter.size, item.size != size {
            return false
        }

        if let category = filter.category, item.category != category {
            return false
        }

        if let occasion = filter.occasion, !item.occasions.contains(occasion) {
            return false
        }

        if let brand = filter.brand, item.brand != brand {
            return false
        }

        if let relationship = filter.relationship, owner(for: item)?.relationship != relationship {
            return false
        }

        return true
    }

    private func uniqueSortedValues(_ keyPath: KeyPath<ThreadItem, String>) -> [String] {
        Array(Set(threadItems.map { $0[keyPath: keyPath] })).sorted()
    }

}
