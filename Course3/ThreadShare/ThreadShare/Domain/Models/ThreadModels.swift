//
//  ThreadModels.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

enum UserRelationship: String, CaseIterable, Codable, Identifiable {
    case friend
    case follower
    case publicUser

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .friend: "Friend"
        case .follower: "Follower"
        case .publicUser: "Public"
        }
    }
}

enum ClothingCategory: String, CaseIterable, Codable, Identifiable {
    case tops
    case bottoms
    case dresses
    case shoes
    case sweaters
    case accessories

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tops: "Tops"
        case .bottoms: "Bottoms"
        case .dresses: "Dresses"
        case .shoes: "Shoes"
        case .sweaters: "Sweaters"
        case .accessories: "Accessories"
        }
    }
}

enum OccasionCategory: String, CaseIterable, Codable, Identifiable {
    case formal
    case casual
    case everyday
    case vacation
    case work
    case gameDay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .formal: "Formal"
        case .casual: "Casual"
        case .everyday: "Everyday"
        case .vacation: "Vacation"
        case .work: "Work"
        case .gameDay: "Game Day"
        }
    }
}

enum ItemCondition: String, CaseIterable, Codable, Identifiable {
    case newWithTags
    case likeNew
    case good
    case worn

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newWithTags: "New With Tags"
        case .likeNew: "Like New"
        case .good: "Good"
        case .worn: "Worn"
        }
    }
}

enum ItemAvailabilityStatus: String, CaseIterable, Codable, Identifiable {
    case available
    case notAvailable
    case requested
    case borrowed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .available: "Available"
        case .notAvailable: "Not Available"
        case .requested: "Requested"
        case .borrowed: "Borrowed"
        }
    }
}

enum BorrowRequestStatus: String, CaseIterable, Codable, Identifiable {
    case pending
    case approved
    case declined
    case returned

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending: "Pending"
        case .approved: "Approved"
        case .declined: "Declined"
        case .returned: "Returned"
        }
    }
}

enum ProfileVisibility: String, CaseIterable, Codable, Identifiable {
    case publicProfile
    case privateProfile
    case friendsOnly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .publicProfile: "Public"
        case .privateProfile: "Private"
        case .friendsOnly: "Friends Only"
        }
    }
}

struct UserProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var displayName: String
    var username: String
    var bio: String
    var avatarImageName: String
    var city: String
    var relationship: UserRelationship
    var visibility: ProfileVisibility
    var followerCount: Int
    var followingCount: Int
    var styleInterests: [String]
    var favoriteBrands: [String]
    var isFollowedByCurrentUser: Bool

    init(
        id: UUID = UUID(),
        displayName: String,
        username: String,
        bio: String,
        avatarImageName: String,
        city: String,
        relationship: UserRelationship,
        visibility: ProfileVisibility,
        followerCount: Int,
        followingCount: Int,
        styleInterests: [String] = [],
        favoriteBrands: [String] = [],
        isFollowedByCurrentUser: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.bio = bio
        self.avatarImageName = avatarImageName
        self.city = city
        self.relationship = relationship
        self.visibility = visibility
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.styleInterests = styleInterests
        self.favoriteBrands = favoriteBrands
        self.isFollowedByCurrentUser = isFollowedByCurrentUser
    }
}

struct ThreadItem: Identifiable, Codable, Hashable {
    let id: UUID
    var ownerID: UserProfile.ID
    var title: String
    var brand: String
    var size: String
    var colorName: String
    var category: ClothingCategory
    var occasions: [OccasionCategory]
    var condition: ItemCondition
    var availabilityStatus: ItemAvailabilityStatus
    var imageName: String
    var photoAspectRatio: Double
    var notes: String
    var fitsLike: String
    var wherePurchased: String
    var purchaseLink: URL?
    var likesCount: Int
    var isLikedByCurrentUser: Bool
    var likedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        ownerID: UserProfile.ID,
        title: String,
        brand: String,
        size: String,
        colorName: String,
        category: ClothingCategory,
        occasions: [OccasionCategory],
        condition: ItemCondition,
        availabilityStatus: ItemAvailabilityStatus,
        imageName: String,
        photoAspectRatio: Double = 1.25,
        notes: String,
        fitsLike: String = "True to size",
        wherePurchased: String = "Unknown",
        purchaseLink: URL? = nil,
        likesCount: Int,
        isLikedByCurrentUser: Bool = false,
        likedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.title = title
        self.brand = brand
        self.size = size
        self.colorName = colorName
        self.category = category
        self.occasions = occasions
        self.condition = condition
        self.availabilityStatus = availabilityStatus
        self.imageName = imageName
        self.photoAspectRatio = max(1, photoAspectRatio)
        self.notes = notes
        self.fitsLike = fitsLike
        self.wherePurchased = wherePurchased
        self.purchaseLink = purchaseLink
        self.likesCount = likesCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.likedAt = likedAt
        self.createdAt = createdAt
    }
}

struct BorrowRequest: Identifiable, Codable, Hashable {
    let id: UUID
    var itemID: ThreadItem.ID
    var requesterID: UserProfile.ID
    var ownerID: UserProfile.ID
    var status: BorrowRequestStatus
    var requestedStartDate: Date
    var requestedEndDate: Date
    var message: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        itemID: ThreadItem.ID,
        requesterID: UserProfile.ID,
        ownerID: UserProfile.ID,
        status: BorrowRequestStatus,
        requestedStartDate: Date,
        requestedEndDate: Date,
        message: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemID = itemID
        self.requesterID = requesterID
        self.ownerID = ownerID
        self.status = status
        self.requestedStartDate = requestedStartDate
        self.requestedEndDate = requestedEndDate
        self.message = message
        self.createdAt = createdAt
    }
}

struct DMMessage: Identifiable, Codable, Hashable {
    let id: UUID
    var senderID: UserProfile.ID
    var recipientID: UserProfile.ID
    var relatedBorrowRequestID: BorrowRequest.ID?
    var body: String
    var sentAt: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        senderID: UserProfile.ID,
        recipientID: UserProfile.ID,
        relatedBorrowRequestID: BorrowRequest.ID? = nil,
        body: String,
        sentAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.senderID = senderID
        self.recipientID = recipientID
        self.relatedBorrowRequestID = relatedBorrowRequestID
        self.body = body
        self.sentAt = sentAt
        self.isRead = isRead
    }
}

struct FriendRequestState: Codable, Hashable {
    var outgoingUserIDs: Set<UserProfile.ID>
    var incomingUserIDs: Set<UserProfile.ID>

    init(
        outgoingUserIDs: Set<UserProfile.ID> = [],
        incomingUserIDs: Set<UserProfile.ID> = []
    ) {
        self.outgoingUserIDs = outgoingUserIDs
        self.incomingUserIDs = incomingUserIDs
    }
}
