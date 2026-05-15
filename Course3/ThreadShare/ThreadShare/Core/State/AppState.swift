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
    var photoAspectRatio: Double = 1.25
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
    case friends
    case following
    case publicUsers

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forYou: "For You"
        case .availableNow: "Available Now"
        case .friends: "Friends"
        case .following: "Following"
        case .publicUsers: "Public"
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var currentUser: UserProfile?
    @Published private(set) var users: [UserProfile] = []
    @Published private(set) var threadItems: [ThreadItem] = []
    @Published private(set) var borrowRequests: [BorrowRequest] = []
    @Published private(set) var messages: [DMMessage] = []
    @Published private(set) var outgoingFriendRequestUserIDs: Set<UserProfile.ID> = []
    @Published private(set) var incomingFriendRequestUserIDs: Set<UserProfile.ID> = []
    @Published var discoverFilter: DiscoverFeedFilter = .forYou
    @Published var threadFilter = ThreadFilter()
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: ThreadRepository

    init(repository: ThreadRepository? = nil) {
        self.repository = repository ?? LocalThreadRepository()
    }

    var filteredItems: [ThreadItem] {
        threadItems
            .filter { item in
                guard let currentUser else { return true }
                return item.ownerID != currentUser.id
            }
            .filter(matchesDiscoverFilter)
            .filter { matchesThreadFilter($0, filter: threadFilter) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var friends: [UserProfile] {
        users
            .filter { user in
                guard let currentUser else { return false }
                return user.id != currentUser.id && user.relationship == .friend
            }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var requestedFriends: [UserProfile] {
        users
            .filter { outgoingFriendRequestUserIDs.contains($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var incomingFriendRequests: [UserProfile] {
        users
            .filter { incomingFriendRequestUserIDs.contains($0.id) }
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

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let currentUser = repository.fetchCurrentUser()
            async let users = repository.fetchUsers()
            async let items = repository.fetchThreadItems()
            async let requests = repository.fetchBorrowRequests()
            async let messages = repository.fetchMessages()
            async let friendRequestState = repository.fetchFriendRequestState()

            self.currentUser = try await currentUser
            self.users = try await users
            self.threadItems = try await items
            self.borrowRequests = try await requests
            self.messages = try await messages
            let persistedFriendRequestState = try await friendRequestState
            self.outgoingFriendRequestUserIDs = persistedFriendRequestState.outgoingUserIDs
            self.incomingFriendRequestUserIDs = persistedFriendRequestState.incomingUserIDs
        } catch {
            errorMessage = "Could not load ThreadShare demo data."
        }

        isLoading = false
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
            .filter(matchesDiscoverFilter)
            .filter { matchesThreadFilter($0, filter: filter) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func owner(for item: ThreadItem) -> UserProfile? {
        users.first { $0.id == item.ownerID }
    }

    func isCurrentUser(id: UserProfile.ID) -> Bool {
        currentUser?.id == id
    }

    func items(for owner: UserProfile) -> [ThreadItem] {
        threadItems
            .filter { $0.ownerID == owner.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func toggleLike(for itemID: ThreadItem.ID) {
        guard let index = threadItems.firstIndex(where: { $0.id == itemID }) else { return }

        threadItems[index].isLikedByCurrentUser.toggle()
        threadItems[index].likesCount += threadItems[index].isLikedByCurrentUser ? 1 : -1
        threadItems[index].likedAt = threadItems[index].isLikedByCurrentUser ? Date() : nil

        let updatedItem = threadItems[index]
        Task {
            try? await repository.saveThreadItem(updatedItem)
            try? await repository.setItemLiked(
                updatedItem.id,
                liked: updatedItem.isLikedByCurrentUser,
                likedAt: updatedItem.likedAt
            )
        }
    }

    func toggleFollow(for userID: UserProfile.ID) {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }

        let wasFollowing = users[index].isFollowedByCurrentUser
        users[index].isFollowedByCurrentUser.toggle()
        users[index].followerCount += users[index].isFollowedByCurrentUser ? 1 : -1

        if users[index].isFollowedByCurrentUser && users[index].relationship == .publicUser {
            users[index].relationship = .follower
        } else if !users[index].isFollowedByCurrentUser && users[index].relationship == .follower {
            users[index].relationship = .publicUser
        }

        if wasFollowing == users[index].isFollowedByCurrentUser {
            return
        }

        let updatedUser = users[index]
        Task {
            try? await repository.saveUser(updatedUser)
            try? await repository.setUserFollowed(updatedUser.id, followed: updatedUser.isFollowedByCurrentUser)
        }
    }

    func requestFriend(for userID: UserProfile.ID) {
        sendFriendRequest(to: userID)
    }

    func sendFriendRequest(to userID: UserProfile.ID) {
        guard let currentUser else { return }
        guard userID != currentUser.id else { return }
        guard !friends.contains(where: { $0.id == userID }) else { return }
        guard !incomingFriendRequestUserIDs.contains(userID) else { return }
        outgoingFriendRequestUserIDs.insert(userID)
        Task {
            try? await repository.sendFriendRequest(to: userID)
        }
    }

    func cancelFriendRequest(to userID: UserProfile.ID) {
        outgoingFriendRequestUserIDs.remove(userID)
        Task {
            try? await repository.cancelFriendRequest(to: userID)
        }
    }

    func approveFriendRequest(from userID: UserProfile.ID) {
        guard let index = users.firstIndex(where: { $0.id == userID }) else { return }
        incomingFriendRequestUserIDs.remove(userID)

        users[index].relationship = .friend
        if !users[index].isFollowedByCurrentUser {
            users[index].isFollowedByCurrentUser = true
            users[index].followerCount += 1
        }

        let updatedUser = users[index]
        Task {
            try? await repository.saveUser(updatedUser)
            try? await repository.approveFriendRequest(from: userID)
        }
    }
    
    func denyFriendRequest(from userID: UserProfile.ID) {
        incomingFriendRequestUserIDs.remove(userID)
        Task {
            try? await repository.denyFriendRequest(from: userID)
        }
    }

    func hasSentFriendRequest(to userID: UserProfile.ID) -> Bool {
        outgoingFriendRequestUserIDs.contains(userID)
    }

    func hasIncomingFriendRequest(from userID: UserProfile.ID) -> Bool {
        incomingFriendRequestUserIDs.contains(userID)
    }

    func visibleFriendRequests(on profile: UserProfile) -> [UserProfile] {
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
    }

    func potentialFriends(matching query: String) -> [UserProfile] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return [] }

        return users
            .filter { user in
                guard let currentUser else { return false }
                guard user.id != currentUser.id else { return false }
                guard user.relationship != .friend else { return false }
                guard !outgoingFriendRequestUserIDs.contains(user.id) else { return false }
                guard !incomingFriendRequestUserIDs.contains(user.id) else { return false }
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
            .filter { $0.isLikedByCurrentUser }
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
        let updatedItem = threadItems[itemIndex]

        Task {
            try? await repository.saveThreadItem(updatedItem)
            try? await repository.saveBorrowRequest(request)
        }

        return request
    }

    func updateBorrowRequest(_ requestID: BorrowRequest.ID, status: BorrowRequestStatus) {
        guard let requestIndex = borrowRequests.firstIndex(where: { $0.id == requestID }) else { return }
        borrowRequests[requestIndex].status = status

        if let itemIndex = threadItems.firstIndex(where: { $0.id == borrowRequests[requestIndex].itemID }) {
            switch status {
            case .pending:
                threadItems[itemIndex].availabilityStatus = .requested
            case .approved:
                threadItems[itemIndex].availabilityStatus = .borrowed
            case .declined, .returned:
                threadItems[itemIndex].availabilityStatus = .available
            }

            let updatedItem = threadItems[itemIndex]
            Task {
                try? await repository.saveThreadItem(updatedItem)
            }
        }

        let updatedRequest = borrowRequests[requestIndex]
        Task {
            try? await repository.saveBorrowRequest(updatedRequest)
        }
    }

    @discardableResult
    func addThreadItem(_ input: NewThreadItemInput) -> ThreadItem? {
        guard let currentUser else { return nil }

        let newItem = ThreadItem(
            ownerID: currentUser.id,
            title: input.title.trimmingCharacters(in: .whitespacesAndNewlines),
            brand: input.brand.trimmingCharacters(in: .whitespacesAndNewlines),
            size: input.size.trimmingCharacters(in: .whitespacesAndNewlines),
            colorName: input.colorName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: input.category,
            occasions: [input.occasion],
            condition: input.condition,
            availabilityStatus: .available,
            imageName: input.imageName,
            photoAspectRatio: max(1, input.photoAspectRatio),
            notes: input.notes.trimmingCharacters(in: .whitespacesAndNewlines),
            fitsLike: input.fitsLike.trimmingCharacters(in: .whitespacesAndNewlines),
            wherePurchased: input.wherePurchased.trimmingCharacters(in: .whitespacesAndNewlines),
            likesCount: 0
        )

        threadItems.insert(newItem, at: 0)
        Task {
            try? await repository.saveThreadItem(newItem)
        }
        return newItem
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
        borrowRequests.removeAll { $0.itemID == itemID }

        Task {
            try? await repository.deleteThreadItem(itemID)
        }

        return true
    }

    private func matchesDiscoverFilter(_ item: ThreadItem) -> Bool {
        switch discoverFilter {
        case .forYou:
            return true
        case .availableNow:
            return item.availabilityStatus == .available
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
