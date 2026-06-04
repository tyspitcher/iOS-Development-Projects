//
//  NotificationModels.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation

enum ThreadNotificationKind: String, CaseIterable, Codable, Identifiable {
    case itemLike = "item_like"
    case itemComment = "item_comment"
    case directMessage = "direct_message"
    case borrowRequest = "borrow_request"
    case borrowRequestStatus = "borrow_request_status"
    case returnReminder = "return_reminder"
    case itemReturned = "item_returned"
    case itemNeedsReturn = "item_needs_return"
    case friendRecentlyAdded = "friend_recently_added"
    case friendTaggedItem = "friend_tagged_item"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .itemLike: "Like"
        case .itemComment: "Comment"
        case .directMessage: "Message"
        case .borrowRequest: "Borrow Request"
        case .borrowRequestStatus: "Request Update"
        case .returnReminder: "Return Reminder"
        case .itemReturned: "Item Returned"
        case .itemNeedsReturn: "Needs Return"
        case .friendRecentlyAdded: "Recently Added"
        case .friendTaggedItem: "Tagged"
        }
    }

    var iconName: String {
        switch self {
        case .itemLike: "heart.fill"
        case .itemComment: "bubble.left.fill"
        case .directMessage: "message.fill"
        case .borrowRequest: "bag.badge.plus"
        case .borrowRequestStatus: "checkmark.seal.fill"
        case .returnReminder: "calendar.badge.clock"
        case .itemReturned: "arrow.uturn.backward.circle.fill"
        case .itemNeedsReturn: "exclamationmark.circle.fill"
        case .friendRecentlyAdded: "sparkles"
        case .friendTaggedItem: "tag.fill"
        }
    }
}

struct ThreadNotification: Identifiable, Codable, Hashable {
    let id: UUID
    var recipientID: UserProfile.ID
    var actorID: UserProfile.ID?
    var kind: ThreadNotificationKind
    var title: String
    var body: String
    var itemID: ThreadItem.ID?
    var borrowRequestID: BorrowRequest.ID?
    var messageID: DMMessage.ID?
    var createdAt: Date
    var readAt: Date?

    var isRead: Bool {
        readAt != nil
    }

    init(
        id: UUID = UUID(),
        recipientID: UserProfile.ID,
        actorID: UserProfile.ID? = nil,
        kind: ThreadNotificationKind,
        title: String,
        body: String,
        itemID: ThreadItem.ID? = nil,
        borrowRequestID: BorrowRequest.ID? = nil,
        messageID: DMMessage.ID? = nil,
        createdAt: Date = Date(),
        readAt: Date? = nil
    ) {
        self.id = id
        self.recipientID = recipientID
        self.actorID = actorID
        self.kind = kind
        self.title = title
        self.body = body
        self.itemID = itemID
        self.borrowRequestID = borrowRequestID
        self.messageID = messageID
        self.createdAt = createdAt
        self.readAt = readAt
    }
}

enum ReturnReminderCadence: String, CaseIterable, Codable, Identifiable {
    case oneTime = "one_time"
    case daily = "daily"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneTime: "One-Time"
        case .daily: "Daily"
        }
    }
}

struct ThreadNotificationPreferences: Codable, Hashable {
    var userID: UserProfile.ID
    var friendNewItemAlertsEnabled: Bool
    var returnReminderCadence: ReturnReminderCadence
    var pushNotificationsEnabled: Bool
    var pushBorrowRequestsEnabled: Bool
    var pushCommentsEnabled: Bool
    var pushMessagesEnabled: Bool
    var pushFriendNewItemsEnabled: Bool
    var pushReturnRemindersEnabled: Bool

    init(
        userID: UserProfile.ID,
        friendNewItemAlertsEnabled: Bool = true,
        returnReminderCadence: ReturnReminderCadence = .oneTime,
        pushNotificationsEnabled: Bool = false,
        pushBorrowRequestsEnabled: Bool = true,
        pushCommentsEnabled: Bool = true,
        pushMessagesEnabled: Bool = true,
        pushFriendNewItemsEnabled: Bool = true,
        pushReturnRemindersEnabled: Bool = true
    ) {
        self.userID = userID
        self.friendNewItemAlertsEnabled = friendNewItemAlertsEnabled
        self.returnReminderCadence = returnReminderCadence
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.pushBorrowRequestsEnabled = pushBorrowRequestsEnabled
        self.pushCommentsEnabled = pushCommentsEnabled
        self.pushMessagesEnabled = pushMessagesEnabled
        self.pushFriendNewItemsEnabled = pushFriendNewItemsEnabled
        self.pushReturnRemindersEnabled = pushReturnRemindersEnabled
    }
}

struct PushDeviceToken: Identifiable, Codable, Hashable {
    let id: UUID
    var userID: UserProfile.ID
    var platform: String
    var token: String
    var enabled: Bool
    var createdAt: Date
    var updatedAt: Date
    var lastRegisteredAt: Date

    init(
        id: UUID = UUID(),
        userID: UserProfile.ID,
        platform: String = "ios",
        token: String,
        enabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastRegisteredAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.platform = platform
        self.token = token
        self.enabled = enabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastRegisteredAt = lastRegisteredAt
    }
}

struct BorrowReturnReminder: Identifiable, Codable, Hashable {
    let id: UUID
    var userID: UserProfile.ID
    var borrowRequestID: BorrowRequest.ID
    var cadence: ReturnReminderCadence
    var nextReminderAt: Date
    var lastSentAt: Date?
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        userID: UserProfile.ID,
        borrowRequestID: BorrowRequest.ID,
        cadence: ReturnReminderCadence,
        nextReminderAt: Date,
        lastSentAt: Date? = nil,
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.borrowRequestID = borrowRequestID
        self.cadence = cadence
        self.nextReminderAt = nextReminderAt
        self.lastSentAt = lastSentAt
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
