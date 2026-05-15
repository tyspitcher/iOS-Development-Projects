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

    init(sessionProvider: SupabaseSessionProviding) {
        self.sessionProvider = sessionProvider
        self.client = SupabaseHTTPClient(sessionProvider: sessionProvider)
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
        return row.toUserProfile(relationship: .publicUser, isFollowedByCurrentUser: false)
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
            follower_count: user.followerCount,
            following_count: user.followingCount,
            created_at: Date(),
            updated_at: Date()
        )
        try await upsert(path: "/rest/v1/profiles", row: row)
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        let row = item.toSupabaseRow()
        try await upsert(path: "/rest/v1/thread_items", row: row)
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        let row = request.toSupabaseRow()
        try await upsert(path: "/rest/v1/borrow_requests", row: row)
    }

    func saveMessage(_ message: DMMessage) async throws {
        let row = message.toSupabaseRow()
        try await upsert(path: "/rest/v1/messages", row: row)
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        try await client.requestVoid(
            path: "/rest/v1/thread_items",
            method: .delete,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(itemID.uuidString)")]
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

        if rows.isEmpty == false {
            try await setUserFollowed(userID, followed: true)
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

    private func upsert<Row: Encodable>(path: String, row: Row) async throws {
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        try await client.requestVoid(
            path: path,
            method: .post,
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
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
}

private extension SupabaseProfileRow {
    func toUserProfile(relationship: UserRelationship, isFollowedByCurrentUser: Bool) -> UserProfile {
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
            styleInterests: style_interests,
            favoriteBrands: favorite_brands,
            isFollowedByCurrentUser: isFollowedByCurrentUser
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
            likesCount: likes_count,
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
