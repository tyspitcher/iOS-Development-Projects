//
//  SwiftDataThreadRepository.swift
//  ThreadShare
//
//  Created by Codex on 5/7/26.
//

import Foundation
import SwiftData

@Model
final class PersistentUserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var username: String
    var bio: String
    var avatarImageName: String
    var city: String
    var relationshipRawValue: String
    var visibilityRawValue: String
    var followerCount: Int
    var followingCount: Int
    var styleInterestsData: Data
    var favoriteBrandsData: Data
    var isFollowedByCurrentUser: Bool

    init(user: UserProfile) {
        self.id = user.id
        self.displayName = user.displayName
        self.username = user.username
        self.bio = user.bio
        self.avatarImageName = user.avatarImageName
        self.city = user.city
        self.relationshipRawValue = user.relationship.rawValue
        self.visibilityRawValue = user.visibility.rawValue
        self.followerCount = user.followerCount
        self.followingCount = user.followingCount
        self.styleInterestsData = Self.encode(user.styleInterests)
        self.favoriteBrandsData = Self.encode(user.favoriteBrands)
        self.isFollowedByCurrentUser = user.isFollowedByCurrentUser
    }

    func update(from user: UserProfile) {
        displayName = user.displayName
        username = user.username
        bio = user.bio
        avatarImageName = user.avatarImageName
        city = user.city
        relationshipRawValue = user.relationship.rawValue
        visibilityRawValue = user.visibility.rawValue
        followerCount = user.followerCount
        followingCount = user.followingCount
        styleInterestsData = Self.encode(user.styleInterests)
        favoriteBrandsData = Self.encode(user.favoriteBrands)
        isFollowedByCurrentUser = user.isFollowedByCurrentUser
    }

    func toUserProfile() -> UserProfile {
        UserProfile(
            id: id,
            displayName: displayName,
            username: username,
            bio: bio,
            avatarImageName: avatarImageName,
            city: city,
            relationship: UserRelationship(rawValue: relationshipRawValue) ?? .publicUser,
            visibility: ProfileVisibility(rawValue: visibilityRawValue) ?? .publicProfile,
            followerCount: followerCount,
            followingCount: followingCount,
            styleInterests: Self.decode(styleInterestsData),
            favoriteBrands: Self.decode(favoriteBrandsData),
            isFollowedByCurrentUser: isFollowedByCurrentUser
        )
    }

    private static func encode(_ values: [String]) -> Data {
        (try? JSONEncoder().encode(values)) ?? Data()
    }

    private static func decode(_ data: Data) -> [String] {
        (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}

@Model
final class PersistentThreadItem {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var title: String
    var brand: String
    var size: String
    var colorName: String
    var categoryRawValue: String
    var occasionsData: Data
    var conditionRawValue: String
    var availabilityStatusRawValue: String
    var imageName: String
    var photoAspectRatio: Double
    var notes: String
    var fitsLike: String
    var wherePurchased: String
    var purchaseLinkString: String?
    var likesCount: Int
    var isLikedByCurrentUser: Bool
    var likedAt: Date?
    var createdAt: Date

    init(item: ThreadItem) {
        self.id = item.id
        self.ownerID = item.ownerID
        self.title = item.title
        self.brand = item.brand
        self.size = item.size
        self.colorName = item.colorName
        self.categoryRawValue = item.category.rawValue
        self.occasionsData = Self.encodeOccasions(item.occasions)
        self.conditionRawValue = item.condition.rawValue
        self.availabilityStatusRawValue = item.availabilityStatus.rawValue
        self.imageName = item.imageName
        self.photoAspectRatio = item.photoAspectRatio
        self.notes = item.notes
        self.fitsLike = item.fitsLike
        self.wherePurchased = item.wherePurchased
        self.purchaseLinkString = item.purchaseLink?.absoluteString
        self.likesCount = item.likesCount
        self.isLikedByCurrentUser = item.isLikedByCurrentUser
        self.likedAt = item.likedAt
        self.createdAt = item.createdAt
    }

    func update(from item: ThreadItem) {
        ownerID = item.ownerID
        title = item.title
        brand = item.brand
        size = item.size
        colorName = item.colorName
        categoryRawValue = item.category.rawValue
        occasionsData = Self.encodeOccasions(item.occasions)
        conditionRawValue = item.condition.rawValue
        availabilityStatusRawValue = item.availabilityStatus.rawValue
        imageName = item.imageName
        photoAspectRatio = item.photoAspectRatio
        notes = item.notes
        fitsLike = item.fitsLike
        wherePurchased = item.wherePurchased
        purchaseLinkString = item.purchaseLink?.absoluteString
        likesCount = item.likesCount
        isLikedByCurrentUser = item.isLikedByCurrentUser
        likedAt = item.likedAt
        createdAt = item.createdAt
    }

    func toThreadItem() -> ThreadItem {
        ThreadItem(
            id: id,
            ownerID: ownerID,
            title: title,
            brand: brand,
            size: size,
            colorName: colorName,
            category: ClothingCategory(rawValue: categoryRawValue) ?? .tops,
            occasions: Self.decodeOccasions(occasionsData),
            condition: ItemCondition(rawValue: conditionRawValue) ?? .good,
            availabilityStatus: ItemAvailabilityStatus(rawValue: availabilityStatusRawValue) ?? .available,
            imageName: imageName,
            photoAspectRatio: photoAspectRatio,
            notes: notes,
            fitsLike: fitsLike,
            wherePurchased: wherePurchased,
            purchaseLink: purchaseLinkString.flatMap(URL.init(string:)),
            likesCount: likesCount,
            isLikedByCurrentUser: isLikedByCurrentUser,
            likedAt: likedAt,
            createdAt: createdAt
        )
    }

    private static func encodeOccasions(_ occasions: [OccasionCategory]) -> Data {
        (try? JSONEncoder().encode(occasions.map(\.rawValue))) ?? Data()
    }

    private static func decodeOccasions(_ data: Data) -> [OccasionCategory] {
        let rawValues = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        let occasions = rawValues.compactMap(OccasionCategory.init(rawValue:))
        return occasions.isEmpty ? [.everyday] : occasions
    }
}

@Model
final class PersistentBorrowRequest {
    @Attribute(.unique) var id: UUID
    var itemID: UUID
    var requesterID: UUID
    var ownerID: UUID
    var statusRawValue: String
    var requestedStartDate: Date
    var requestedEndDate: Date
    var message: String
    var createdAt: Date

    init(request: BorrowRequest) {
        self.id = request.id
        self.itemID = request.itemID
        self.requesterID = request.requesterID
        self.ownerID = request.ownerID
        self.statusRawValue = request.status.rawValue
        self.requestedStartDate = request.requestedStartDate
        self.requestedEndDate = request.requestedEndDate
        self.message = request.message
        self.createdAt = request.createdAt
    }

    func update(from request: BorrowRequest) {
        itemID = request.itemID
        requesterID = request.requesterID
        ownerID = request.ownerID
        statusRawValue = request.status.rawValue
        requestedStartDate = request.requestedStartDate
        requestedEndDate = request.requestedEndDate
        message = request.message
        createdAt = request.createdAt
    }

    func toBorrowRequest() -> BorrowRequest {
        BorrowRequest(
            id: id,
            itemID: itemID,
            requesterID: requesterID,
            ownerID: ownerID,
            status: BorrowRequestStatus(rawValue: statusRawValue) ?? .pending,
            requestedStartDate: requestedStartDate,
            requestedEndDate: requestedEndDate,
            message: message,
            createdAt: createdAt
        )
    }
}

@Model
final class PersistentDMMessage {
    @Attribute(.unique) var id: UUID
    var senderID: UUID
    var recipientID: UUID
    var relatedBorrowRequestID: UUID?
    var body: String
    var sentAt: Date
    var isRead: Bool

    init(message: DMMessage) {
        self.id = message.id
        self.senderID = message.senderID
        self.recipientID = message.recipientID
        self.relatedBorrowRequestID = message.relatedBorrowRequestID
        self.body = message.body
        self.sentAt = message.sentAt
        self.isRead = message.isRead
    }

    func update(from message: DMMessage) {
        senderID = message.senderID
        recipientID = message.recipientID
        relatedBorrowRequestID = message.relatedBorrowRequestID
        body = message.body
        sentAt = message.sentAt
        isRead = message.isRead
    }

    func toDMMessage() -> DMMessage {
        DMMessage(
            id: id,
            senderID: senderID,
            recipientID: recipientID,
            relatedBorrowRequestID: relatedBorrowRequestID,
            body: body,
            sentAt: sentAt,
            isRead: isRead
        )
    }
}

@Model
final class PersistentFriendRequestState {
    @Attribute(.unique) var id: String
    var outgoingUserIDsData: Data
    var incomingUserIDsData: Data

    init(state: FriendRequestState, id: String = "current-user-friend-request-state") {
        self.id = id
        self.outgoingUserIDsData = Self.encode(state.outgoingUserIDs)
        self.incomingUserIDsData = Self.encode(state.incomingUserIDs)
    }

    func update(from state: FriendRequestState) {
        outgoingUserIDsData = Self.encode(state.outgoingUserIDs)
        incomingUserIDsData = Self.encode(state.incomingUserIDs)
    }

    func toFriendRequestState() -> FriendRequestState {
        FriendRequestState(
            outgoingUserIDs: Self.decode(outgoingUserIDsData),
            incomingUserIDs: Self.decode(incomingUserIDsData)
        )
    }

    private static func encode(_ ids: Set<UUID>) -> Data {
        (try? JSONEncoder().encode(ids.map(\.uuidString))) ?? Data()
    }

    private static func decode(_ data: Data) -> Set<UUID> {
        let rawIDs = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        return Set(rawIDs.compactMap(UUID.init(uuidString:)))
    }
}

@MainActor
final class SwiftDataThreadRepository: ThreadRepository {
    static let schema = Schema([
        PersistentUserProfile.self,
        PersistentThreadItem.self,
        PersistentBorrowRequest.self,
        PersistentDMMessage.self,
        PersistentFriendRequestState.self
    ])

    private let context: ModelContext

    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }

    func fetchCurrentUser() async throws -> UserProfile {
        try seedIfNeeded()
        let users = try context.fetch(FetchDescriptor<PersistentUserProfile>())
        return users.first { $0.id == SampleData.currentUser.id }?.toUserProfile() ?? SampleData.currentUser
    }

    func fetchUsers() async throws -> [UserProfile] {
        try seedIfNeeded()
        return try context.fetch(FetchDescriptor<PersistentUserProfile>())
            .map { $0.toUserProfile() }
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        try seedIfNeeded()
        return try context.fetch(FetchDescriptor<PersistentThreadItem>())
            .map { $0.toThreadItem() }
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        try seedIfNeeded()
        return try context.fetch(FetchDescriptor<PersistentBorrowRequest>())
            .map { $0.toBorrowRequest() }
    }

    func fetchMessages() async throws -> [DMMessage] {
        try seedIfNeeded()
        return try context.fetch(FetchDescriptor<PersistentDMMessage>())
            .map { $0.toDMMessage() }
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        try seedIfNeeded()
        return try context.fetch(FetchDescriptor<PersistentFriendRequestState>())
            .first?
            .toFriendRequestState() ?? FriendRequestState()
    }

    func saveUser(_ user: UserProfile) async throws {
        let models = try context.fetch(FetchDescriptor<PersistentUserProfile>())
        if let model = models.first(where: { $0.id == user.id }) {
            model.update(from: user)
        } else {
            context.insert(PersistentUserProfile(user: user))
        }
        try context.save()
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        let models = try context.fetch(FetchDescriptor<PersistentThreadItem>())
        if let model = models.first(where: { $0.id == item.id }) {
            model.update(from: item)
        } else {
            context.insert(PersistentThreadItem(item: item))
        }
        try context.save()
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        let models = try context.fetch(FetchDescriptor<PersistentBorrowRequest>())
        if let model = models.first(where: { $0.id == request.id }) {
            model.update(from: request)
        } else {
            context.insert(PersistentBorrowRequest(request: request))
        }
        try context.save()
    }

    func saveMessage(_ message: DMMessage) async throws {
        let models = try context.fetch(FetchDescriptor<PersistentDMMessage>())
        if let model = models.first(where: { $0.id == message.id }) {
            model.update(from: message)
        } else {
            context.insert(PersistentDMMessage(message: message))
        }
        try context.save()
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        let models = try context.fetch(FetchDescriptor<PersistentFriendRequestState>())
        if let model = models.first {
            model.update(from: state)
        } else {
            context.insert(PersistentFriendRequestState(state: state))
        }
        try context.save()
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        let items = try context.fetch(FetchDescriptor<PersistentThreadItem>())
        items
            .filter { $0.id == itemID }
            .forEach { context.delete($0) }

        let requests = try context.fetch(FetchDescriptor<PersistentBorrowRequest>())
        requests
            .filter { $0.itemID == itemID }
            .forEach { context.delete($0) }

        try context.save()
    }

    private func seedIfNeeded() throws {
        var didInsertSeedData = false

        let existingUserIDs = Set(try context.fetch(FetchDescriptor<PersistentUserProfile>()).map(\.id))
        for user in SampleData.users where !existingUserIDs.contains(user.id) {
            context.insert(PersistentUserProfile(user: user))
            didInsertSeedData = true
        }

        let existingItemIDs = Set(try context.fetch(FetchDescriptor<PersistentThreadItem>()).map(\.id))
        for item in SampleData.threadItems where !existingItemIDs.contains(item.id) {
            context.insert(PersistentThreadItem(item: item))
            didInsertSeedData = true
        }

        let existingRequestIDs = Set(try context.fetch(FetchDescriptor<PersistentBorrowRequest>()).map(\.id))
        for request in SampleData.borrowRequests where !existingRequestIDs.contains(request.id) {
            context.insert(PersistentBorrowRequest(request: request))
            didInsertSeedData = true
        }

        let existingMessageIDs = Set(try context.fetch(FetchDescriptor<PersistentDMMessage>()).map(\.id))
        for message in SampleData.dmMessages where !existingMessageIDs.contains(message.id) {
            context.insert(PersistentDMMessage(message: message))
            didInsertSeedData = true
        }

        let existingFriendRequestStates = try context.fetch(FetchDescriptor<PersistentFriendRequestState>())
        if existingFriendRequestStates.isEmpty {
            context.insert(
                PersistentFriendRequestState(
                    state: FriendRequestState(incomingUserIDs: [SampleData.users[5].id])
                )
            )
            didInsertSeedData = true
        }

        if didInsertSeedData {
            try context.save()
        }
    }
}
