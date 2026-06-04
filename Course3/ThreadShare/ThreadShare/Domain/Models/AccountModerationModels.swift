//
//  AccountModerationModels.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import Foundation

enum AccountDeletionRequestStatus: String, Codable {
    case pending
    case canceled
    case completed
}

enum ImmediateAccountDeletionStatus: String, Codable {
    case backendRequired
}

struct AccountDeletionRequest: Codable, Equatable {
    static let gracePeriodDays = 14

    let userID: UUID
    let requestedAt: Date
    let scheduledDeletionDate: Date
    var status: AccountDeletionRequestStatus
    var canceledAt: Date?
    var completedAt: Date?

    init(
        userID: UUID,
        requestedAt: Date = Date(),
        scheduledDeletionDate: Date? = nil,
        status: AccountDeletionRequestStatus = .pending,
        canceledAt: Date? = nil,
        completedAt: Date? = nil,
        calendar: Calendar = .current
    ) {
        self.userID = userID
        self.requestedAt = requestedAt
        self.scheduledDeletionDate = scheduledDeletionDate ?? calendar.date(
            byAdding: .day,
            value: Self.gracePeriodDays,
            to: requestedAt
        ) ?? requestedAt.addingTimeInterval(TimeInterval(Self.gracePeriodDays * 24 * 60 * 60))
        self.status = status
        self.canceledAt = canceledAt
        self.completedAt = completedAt
    }
}

struct ImmediateAccountDeletionNotice: Codable, Equatable {
    let userID: UUID
    let requestedAt: Date
    let confirmationStatement: String
    let backendRequirementMessage: String
    var status: ImmediateAccountDeletionStatus

    init(
        userID: UUID,
        requestedAt: Date = Date(),
        confirmationStatement: String,
        backendRequirementMessage: String,
        status: ImmediateAccountDeletionStatus = .backendRequired
    ) {
        self.userID = userID
        self.requestedAt = requestedAt
        self.confirmationStatement = confirmationStatement
        self.backendRequirementMessage = backendRequirementMessage
        self.status = status
    }
}

enum ItemReportReason: String, CaseIterable, Codable, Identifiable {
    case inappropriate = "Inappropriate Content"
    case misleading = "Misleading Listing"
    case spam = "Spam"
    case counterfeit = "Counterfeit Concern"
    case brokenLink = "Broken Link"
    case linkInappropriate = "Inappropriate"
    case notCorrectItem = "Not the Correct Item"
    case other = "Other"

    var id: String { rawValue }
}

struct ItemReport: Identifiable, Codable, Equatable {
    let id: UUID
    let reporterID: UUID
    let itemID: UUID
    let ownerID: UUID
    let reason: ItemReportReason
    let details: String
    let status: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        reporterID: UUID,
        itemID: UUID,
        ownerID: UUID,
        reason: ItemReportReason,
        details: String,
        status: String = "open",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reporterID = reporterID
        self.itemID = itemID
        self.ownerID = ownerID
        self.reason = reason
        self.details = details
        self.status = status
        self.createdAt = createdAt
    }
}
